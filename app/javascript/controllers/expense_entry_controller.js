import { Controller } from "stimulus";

// This controller corresponds to an ExpenseEntry in the database.  Each ExpenseEntry in the HTML/Javascript world
// is made up of a div -> form.  Both are handled thru one controller, with the form being accessed as a target.
//
// This controller has three areas of concern:
// * managing the activities when a row gets replaced.  This is usually the result of submitting the form associated
//   with the row, and getting a new form back (either because its now a saved object, or because an update has
//   generated errors.
// * managing the dragging and dropping of rows in the table
// * updating key fields in the form depending on other changes made in the row by the user.
export default class ExpenseEntryController extends Controller {
    static targets = [ "form", "category", "description", "vat", "qty", "unitCost", "totalCost", "claimTotal",
        "receiptImage", "emailReceiptToken" ];

    // First time that we are connected,
    connect() {
        this.modal = document.getElementById('receipt-modal');
        this.currentReceiptForm = this.modal.querySelector('#current-receipt-form');
        this.imageDiv = this.modal.querySelector("#current-receipt-image-placeholder");
    }

    ajaxSuccessThereforeResetErrors(event) {
        for(let element of this.element.getElementsByClassName('is-invalid')) {
            element.classList.remove('is-invalid');
        }
        for(let element of this.element.getElementsByTagName('small')) {
            element.remove();
        }
    }

    // See https://jsfiddle.net/a6tgy9so/1/.  On receiving the mousedown for the sequence field, we make the whole
    // expense_entry div draggable.
    mousedown(event) {
        this.element.setAttribute('draggable', 'true');
    }

    // On receiving the mouseup event for the sequence field, we remove the draggable from the div
    mouseup(event) {
        this.element.setAttribute('draggable', 'false');
    }

    // We store the id (which is either the database id for existing expense_entry, or we store the timestamp of when
    // we created the new row for objects not yet saved in the database.
    dragstart(event) {
        event.dataTransfer.effectAllowed = "move";
        event.dataTransfer.setData("text/plain", this.element.id);
    }

    // Ensure we don't do anything when the user traverses an element that could receive a drop.
    dragenter(event) {
        event.preventDefault()
    }

    // We model the fact that we can re-arrange the rows by allowing each row to receive a drop event.  Hence, this
    // method.
    dragover(event) {
        event.preventDefault();
        return true;
    }

    // Event handler for when the user drops the row they are dragging onto an existing row.  Causes us to insert
    // the dragged row ahead of the dropped row and then to resequence the rows.
    drop(event) {
        console.log('drop for', this.element);
        let id = event.dataTransfer.getData("text/plain");
        this.element.parentElement.insertBefore(document.getElementById(id), this.element);
        this.element.dispatchEvent(new CustomEvent('resequence', { bubbles: true }));
        event.preventDefault();
    }

    // Event handler for change event.  Flag this row as having pending changes.  Next time we push updates to the
    // backend this row will also be pushed.
    changeEvent(event) {
        this.formTarget.dataset.expenseEntryChanged = '1';
    }

    // Event handler for when the user selects a particular expenses claim category
    categoryChange(event) {
        let dataset = event.srcElement.selectedOptions[0].dataset;
        this.vatTarget.value = dataset.vat;
        if (dataset.unitcost != "") {
            this.unitCostTarget.value = dataset.unitcost;
        }
        this.recalcClaim(event);
        this.changeEvent(event);
    }

    // Event handler for when the user changes a field that affects the total cost of the claim.
    recalcClaim(event) {
        this.totalCostTarget.value = (parseFloat(this.unitCostTarget.value) * parseInt(this.qtyTarget.value)).toFixed(2);
        this.changeEvent(event);
        this.element.dispatchEvent(new CustomEvent('recalcTotalClaim', { bubbles: true}));
    }

    // Event handler for when the user hits the cross to remove the contents of the description field.
    // Invokes preventDefault() to stop a focusIn event being generated that causes the row with the
    // empty description being sent to the backend.
    clearDescription(event) {
        this.descriptionTarget.value = "";
        event.preventDefault();
    }

    // Event handler for when the user selects a description in the CC dropdown.  Copies it into the current description
    // and generates a change event.
    copyDescriptionFromCC(event) {
        this.descriptionTarget.value = event.srcElement.text;
        this.descriptionTarget.changeEvent(new Event('change'));
    }

    // Event handler for when the user hits the receipt upload button:
    // * copy the current image into the Current Receipt tab and set URL target
    // * copies the destination from the current form
    // * sets the delete action to point at the current expense entry
    // * removes a previous child if it existed
    // * ensures the file selector field is enabled
    receiptUpload(event) {
        this.setupExistingReceiptForm();
        this.setupUploadForm('file-upload-form', 'fileReceipt');
        this.setupUploadForm('receipt-image-url-form', 'fileReceipt');
        this.setupUploadForm('receipt-from-email-form', 'emailReceipt');
    }


    // If an image has already been uploaded, then a reference to it is held in the expense-entry div.  Copy that
    // reference to the modal so the user sees what has already been uploaded.
    setupExistingReceiptForm() {
        let isEmailReceipt = this.data.get('emailReceiptMethod') == 'PUT';
        this.currentReceiptForm.action = this.data.get( (isEmailReceipt) ? 'emailReceiptAction' : 'fileReceiptAction');

        if (this.imageDiv.lastElementChild != null) {
            this.imageDiv.removeChild(this.imageDiv.lastElementChild);
        }

        // Show resize buttons on current form so long as current receipt not an email.
        this.setupReceiptSizeButtons(this.currentReceiptForm, !isEmailReceipt);

        if (this.hasReceiptImageTarget) {
            let image = this.receiptImageTarget.cloneNode(true);
            this.copyImageToModal(image);
        } else {
            this.imageDiv.innerHTML = "<p>No receipt uploaded</p>";
        }

        this.setupDeleteButton();
    }

    copyImageToModal(image) {
        image.hidden = false;
        this.imageDiv.appendChild(image);
    }

    // Common code to configure each form according to what already exists.
    setupUploadForm(form_id, target_name) {
        let form = document.getElementById(form_id);
        let action = `${target_name}Action`;
        let method = `${target_name}Method`;

        this.setupReceiptSizeButtons(form, form!=='receipt-from-email-form');

        form.querySelector("input[type='hidden'][name='_method']").disabled = this.data.get(method) == 'POST';
        form.action = this.data.get(action);
    }

    setupReceiptSizeButtons(form, show) {
        let receiptSize = this.data.get('receiptSize');

        form.querySelectorAll('.receipt-size').forEach(receiptSizeButton => {
            if (show) {
                receiptSizeButton.hidden = false;
                if (receiptSizeButton.firstElementChild.value == receiptSize) {
                    receiptSizeButton.classList.add("active");
                    receiptSizeButton.firstElementChild.checked = true;
                } else {
                    receiptSizeButton.classList.remove("active");
                    receiptSizeButton.firstElementChild.checked = false;
                }
            } else {
                receiptSizeButton.hidden = true;
            }
        });
    }

    // Puts the correct action on each of the Delete buttons depending on what type of receipt we are currently dealing
    // with.
    setupDeleteButton() {
        var action;

        if (this.data.get('fileReceiptMethod') == 'PUT') {
            action = this.data.get('fileReceiptAction');
        } else if (this.data.get('emailReceiptMethod') == 'PUT') {
            action = this.data.get('emailReceiptAction');
        } else {
            action = '#';
        }

        let deleteButton = this.modal.querySelector(".delete-btn");
        deleteButton.href = action;
        deleteButton.disabled = action=='#';
        deleteButton.method = 'DELETE';
    }
}
