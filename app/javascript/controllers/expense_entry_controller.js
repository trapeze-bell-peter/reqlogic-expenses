import { Controller } from "stimulus";
import Rails from "rails-ujs";

// This controller corresponds to an ExpenseEntry in the database.  Each ExpenseEntry in the HTML/Javascript world
// is made up of a div -> form.  Both are handled thru one controller, with the form being accessed as a target.
//
// This controller has two three areas of concern:
// * managing the activities when a row gets replaced.  This is usually the result of submitting the form associated
//   with the row, and getting a new form back (either because its now a saved object, or because an update has
//   generated errors.
// * managing the dragging and dropping of rows in the table
// * updating key fields in the form depending on other changes made in the row by the user.
export default class ExpenseEntryController extends Controller {
    static targets = [ 'form', "category", "vat", "qty", "unitCost", "totalCost", "claimTotal" ];

    // First time that we are connected,
    connect() {
    }

    ajaxSuccessThereforeResetErrors(event) {
        for(let element of this.element.getElementsByClassName('is-invalid')) {
            element.classList.remove('is-invalid');
        }
        for(let element of this.element.getElementsByTagName('small')) {
            element.remove();
        }
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
        this.element.dataset.changePending = '1';
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
}
