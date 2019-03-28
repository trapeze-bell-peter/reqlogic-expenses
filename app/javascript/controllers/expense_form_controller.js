import { Controller } from "stimulus";
import Rails from "rails-ujs";

export default class ExpenseFormController extends Controller {
    static targets = [ "category", "vat", "qty", "unitCost", "totalCost" ];

    connect() {
        console.log('hello from ExpenseFormController');
        this.recalcClaim(null);
        this.emitResequenceRequired();
    }

    // Generate a custom event that the ExpenseRowsController is listening for.  It takes responsibility for
    // re-sequencing the rows so that the correct sequence numbers are stored in the database.
    emitResequenceRequired() {
        console.log("in emitReqsequenceRequired");
        this.element.dispatchEvent(new CustomEvent('resequence', { bubbles: true}));
    }

    // Event handler for change event.  Flag this row as having pending changes.  Next time we push updates to the
    // backend this row will also be pushed.
    changeEvent(event) {
        this.data.set('changePending', '1');
    }

    // Event handler for when the user selects a particular expenses claim category
    categoryChange(event) {
        let dataset = event.srcElement.selectedOptions[0].dataset;
        this.vatTarget.value = dataset.vat;
        this.unitCostTarget.value = dataset.unitcost;
    }

    // Event handler for when the user changes a field that affects the total cost of the claim.
    recalcClaim(event) {
        this.totalCostTarget.value = (parseFloat(this.unitCostTarget.value) * parseInt(this.qtyTarget.value)).toFixed(2);
    }
}

