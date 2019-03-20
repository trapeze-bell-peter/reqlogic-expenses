import { Controller } from "stimulus"

export default class extends Controller {
    static targets = [ "category", "vat", "unitCost" ];

    categoryChange(event) {
        console.log("Hello, categoryChange!", this.element);

        let dataset = event.srcElement.selectedOptions[0].dataset
        this.vatTarget.value = dataset.vat;
        this.unitCostTarget.value = dataset.unitcost;
    }
}