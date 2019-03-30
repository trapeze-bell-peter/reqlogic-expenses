import { Controller } from "stimulus";
import Rails from "rails-ujs";

export default class ExpenseRowsController extends Controller {
    static targets = [ "form", "sequenceField", "totalCost", "totalClaim" ];

    connect() {
        this.resequence();
    }

    disconnect() {
        this.resequence();
        this.submitChangedForms();
    }

    // Method to resequence expense entries after something has changed in the rows
    resequence(event = null) {
        console.log('Hello from ExpenseEntryController#resequence');

        this.sequenceFieldTargets.forEach( (target, index) => {
            if (parseInt(target.value)!=index) {
                console.log(target);
                target.value = index;
                target.form.dataset.changePending = '1';
            }
        } );
    }

    // Event handler for when a focusin event has occured within the rows.  We now loop thru all rows, and any rows
    // other than the current row that have the change-pending flag we generate a submit form.
    submitChangedForms(event = null) {
        console.log('Hello from ExpenseEntryController#submitChangedRows');

        this.formTargets.forEach(
            function(form) {
                if (event==null || form != event.target.form) {
                    if (form.hidden) {
                        form.remove();
                        this.emitResequenceRequired();
                    } else if (form.dataset.expenseFormChangePending == '1') {
                        form.dataset.changePending = '0';
                        console.log('submitting', form)
                        Rails.fire(form, 'submit');
                    }
                }
            }, this);
    }

    sumTotalCosts(event) {
        let overallCost = 0.0;
        this.totalCostTargets.forEach( totalCostField => { overallCost += parseFloat(totalCostField.value); });
        this.totalClaimTarget.value = overallCost.toFixed(2);
    }
}