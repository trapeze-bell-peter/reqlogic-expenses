import { Controller } from "stimulus";
import Rails from "rails-ujs";

export default class ExpenseClaimController extends Controller {
    static targets = [ "expenseEntryForm", "claimForm", "sequenceField", "totalCost", "totalClaim", "claimTable" ];

    connect() {
        console.log("Hello from ExpenseClaimController");
    }

    // Event handler for when the controller gets disconnected.  We resequence and then submit any changed rows.
    disconnect() {
        this.reSequenceExpenseEntryForms();
        this.submitChangedExpenseEntryForms();
    }

    // Event handler for when the user hits the Excel button.  Just make double sure we have saved everything
    // before we start the download.
    excelDownload() {
        this.reSequenceExpenseEntryForms();
        this.submitChangedExpenseEntryForms();
    }

    // Event
    changeClaim(event) {
        Rails.fire(this.claimFormTarget, 'submit');
    }

    // Event handler for a completed AJAX submission to the backend for the claim fields.  There are two possible
    // outcomes:
    // * if this is an existing entry and there are no issues with it, we simply accept the response.
    // * If a field in the claim has issues then an HTML chunk will be returned
    //   and we need to replace the existing claim div with the one returned by the backend.
    ajaxClaimSubmitComplete(event) {
        console.log('ajaxClaimSubmitComplete#ajaxComplete invoked');

        event.preventDefault();

        let [data, status, xhr] = event.detail;

        if (status!=='OK' || data.responseText !== "") {
            let wrapper= document.createElement('div');
            wrapper.innerHTML= data.responseText;
            event.target.closest('div.expense-claim-key-data').replaceWith(wrapper.firstChild);
        }
    }

    // Event handler for when the user presses the insert on an expense-entry row.  We submit any changed forms,
    // identify the insertion point, create a copy of the template empty row and insert it.  We then re-sequence,
    // but do not save.  This gives the user the chance to fill in the new row, and also remove if they change their
    // mind without requiring changes in the backend.
    insertExpenseEntry(event) {
        event.preventDefault();

        this.submitChangedExpenseEntryForms();

        let expenseEntryInsertPoint = event.currentTarget.closest('div.expense-entry');
        expenseEntryInsertPoint.insertAdjacentElement('afterend', this.createEmptyExpenseEntry());

        this.reSequenceExpenseEntryForms();
    }

    // Event handler to copy row.  It does this by fetching an empty row from the backend and then copying the
    // input elements across.
    copyExpenseEntry(event) {
        event.preventDefault();

        this.submitChangedExpenseEntryForms();

        let expenseEntrySource = event.currentTarget.closest('div.expense-entry');
        let expenseEntryCopy = this.createEmptyExpenseEntry();

        this.copyInputElements(expenseEntrySource, expenseEntryCopy);
        this.claimTableTarget.appendChild(expenseEntryCopy);

        this.reSequenceExpenseEntryForms();
    }

    // Event handler for when the user presses the delete on an expense row.  The Ajax request has already been
    // sent and the record deleted in the backend.
    deleteExpenseEntry(event) {
        let owningExpenseEntryDiv = event.currentTarget.closest('div.expense-entry');
        owningExpenseEntryDiv.remove();
        this.reSequenceExpenseEntryForms();
    }

    // Event handler for when the user clicks into an input field.  If the click is away from the current row
    // we send any changed rows to the backend.  We then set the current expense entry to the new row.  That means
    // that if the user clicks on any fields in the current row, this will not generate a refresh.  They need to
    // click into a new row to make that happen.
    focusOnExpenseEntry(event) {
        let owningExpenseEntryDiv = event.target.closest('div.expense-entry');
        let newCurrentExpenseEntryId = owningExpenseEntryDiv.id;

        if (this.data.get('currentExpenseEntry') !== newCurrentExpenseEntryId) {
            this.submitChangedExpenseEntryForms();
        }

        this.data.set('currentExpenseEntry', newCurrentExpenseEntryId);
    }


    // Event handler for when the user makes a change to an input field.  We mark the row having been edited as
    // requiring to be submitted.  This means that the next time the user clicks in another expense entry row
    // {focusOnExpenseEntry} will submit this row. In practice this means that every time the user clicks into a new
    // row any unsaved changes are submitted.
    changeToExpenseEntry(event) {
        event.target.form.dataset.expenseEntryChanged = '1';
    }

    // Event handler for a completed AJAX submission to the backend.  There are two possible outcomes:
    // * if this is an existing entry and there are no issues with it, we simply accept the response.
    // * If this is a new entry, or an existing entry with issues, then an HTML chunk will be returned
    //   and we need to replace the existing expense entry div with the one returned by the backend.
    ajaxComplete(event) {
        console.log('ExpenseClaimController#ajaxSuccess invoked');

        event.preventDefault();

        let [data, status, xhr] = event.detail;

        if (status!=='OK' || data.responseText !== "") {
            let wrapper= document.createElement('div');
            wrapper.innerHTML= data.responseText;
            event.target.closest('div.expense-entry').replaceWith(wrapper.firstChild);
        }
    }

    // Supporting method to re-sequence expense entries after something has changed the sequence of rows
    // (insert, copy, move or delete).  If sequence number has changed, then a submit is fired for the corresponding
    // form.
    reSequenceExpenseEntryForms() {
        console.log('Hello from ExpenseClaimController#reSequenceExpenseEntryForms');

        let sequenceIndex = 0;

        this.sequenceFieldTargets.forEach( sequenceField => {
            let owningExpenseEntryDiv = sequenceField.closest('div.expense-entry');
            if (!owningExpenseEntryDiv.hidden && parseInt(sequenceField.value)!=sequenceIndex) {
                sequenceField.value = sequenceIndex;
                sequenceField.form.dataset.expenseEntryChanged = '1';
            }
            sequenceIndex++;
        } );

        this.submitChangedExpenseEntryForms();
    }

    // Helper method to submit any expense entry forms that are flagged as having changed.  Any hidden expense entry
    // divs are not submitted on purpose, but instead removed from the DOM.
    submitChangedExpenseEntryForms() {
        console.log('Hello from ExpenseClaimController#submitChangedExpenseEntryForms');

        this.expenseEntryFormTargets.forEach( form => {
            if (form.dataset.expenseEntryChanged == '1') {
                form.dataset.expenseEntryChanged = '0';
                Rails.fire(form, 'submit');
            }
        });
    }

    recalcTotalClaim(event) {
        let overallCost = 0.0;
        this.totalCostTargets.forEach( totalCostField => { overallCost += parseFloat(totalCostField.value); });
        this.totalClaimTarget.value = overallCost.toFixed(2);
    }

    // Get the empty row out of the template, clone it, and give it and id of the current time.
    createEmptyExpenseEntry() {
        let template = document.getElementById('expense-entry-empty-row');
        let newExpenseEntry = template.content.getElementById('expense-entry-empty-row').cloneNode(true);
        newExpenseEntry.id = `expense-entry-${Date.now()}`;
        return newExpenseEntry;
    }

    // Given the new row, copy all inputs across from the current row.
    copyInputElements(srcExpenseEntry, dstExpenseEntry) {
        for(let elementType of ['input', 'select']) {
            let elements = dstExpenseEntry.getElementsByTagName(elementType);
            for(let i=0; i< elements.length; i++) {
                if (elements[i].type!=='hidden') {
                    elements[i].value = srcExpenseEntry.querySelector(`${elementType}#${elements[i].id}`).value
                }
            }
        }
    }


}