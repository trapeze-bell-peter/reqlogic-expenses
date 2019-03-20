import { Controller } from "stimulus"

export default class extends Controller {
    static targets = [ "category", "vat", "qty", "unitCost", "totalCost" ];

    // Event handler for when the user selects a particular expenses claim category
    categoryChange(event) {
        let dataset = event.srcElement.selectedOptions[0].dataset;
        this.vatTarget.value = dataset.vat;
        this.unitCostTarget.value = dataset.unitcost;
    }

    recalcClaim(event) {
        console.log("Hello, recalcClaim!", this.element);
        this.totalCostTarget.value = parseFloat(this.unitCostTarget.value) * parseInt(this.qtyTarget.value)
    }
}