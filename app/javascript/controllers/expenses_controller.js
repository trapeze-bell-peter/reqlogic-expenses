import { Controller } from "stimulus";
import Rails from "rails-ujs";

export default class extends Controller {
    static targets = [ "row", "category", "vat", "qty", "unitCost", "totalCost" ];

    // Event handler for when the user selects a particular expenses claim category
    categoryChange(event) {
        let dataset = event.srcElement.selectedOptions[0].dataset;
        this.vatTarget.value = dataset.vat;
        this.unitCostTarget.value = dataset.unitcost;
    }

    // Event handler for when the user changes a field that affects the total cost of the claim.
    recalcClaim(event) {
        console.log("Hello, recalcClaim!", this.element);
        this.totalCostTarget.value = (parseFloat(this.unitCostTarget.value) * parseInt(this.qtyTarget.value)).toFixed(2)
    }

    // Event handler for when the user leaves a row and we can push the results back to the controller
    submitRow(event) {
        console.log("Hello, submitRow!", this.element);
        event.preventDefault();

        // The process of hiding the row causes a loss of focus.  Don't send an update in this case to the backend.
        Rails.fire(this.element.firstElementChild, 'submit');
    }

    // ToDo: Event handler for when an error is reported back by RoR backend
    errorOnRow(event) {
        console.log("Hello, errorOnRow!", this.element);
    }

    // Event handler for when the user presses the insert on an expesne row.
    insertRow(event) {
        console.log("Hello, insertEntry!", this.element);
        event.preventDefault();

        fetch(event.currentTarget.href)
            .then( response => { return response.text(); })
            .then( html => { this.rowTarget.insertAdjacentHTML('afterend', html); });
    }

    // Event handler for when the user presses the delete on an expense row.
    deleteRow(event) {
        console.log("Hello, deleteEntry!", this.element);
        this.element.remove();
    }
}

