import { Controller } from "stimulus";
import Rails from "rails-ujs";

export default class extends Controller {
    static targets = [ "category", "vat", "qty", "unitCost", "totalCost" ];

    // Event handler for when the user selects a particular expenses claim category
    categoryChange(event) {
        let dataset = event.srcElement.selectedOptions[0].dataset;
        this.vatTarget.value = dataset.vat;
        this.unitCostTarget.value = dataset.unitcost;
    }

    // Event handler for when the user changes a field that affects the total cost of the claim.
    recalcClaim(event) {
        console.log("Hello, recalcClaim!", this.element);
        this.totalCostTarget.value = parseFloat(this.unitCostTarget.value) * parseInt(this.qtyTarget.value)
    }

    // Event handler for when the user leaves a row and we can push the results back to the controller
    submitRow(event) {
        console.log("Hello, submitClaim!", this.element);
        event.preventDefault();
        Rails.fire(event.currentTarget, 'submit');
    }

    errorOnRow(event) {
        console.log("Hello, errorOnRow!", this.element);
    }
}