import { Controller } from "stimulus";
import Rails from "rails-ujs";

export default class ExpenseEntryController extends Controller {
    static targets = [ "category", "vat", "qty", "unitCost", "totalCost" ];

    connect() {
        console.log("Hello from expense_entry");

        this.recalcClaim(null);
    }

    // Event handler for change event.  We use the opportunity to check if any of the other controllers have pending
    // changes.
    changeEvent(event) {
        console.log("Hello, changeEvent!", this.element);
        this.data.set('changePending', '1');
    }

    focusEvent(event) {
        console.log("Hello, focusEvent!", this.element);
        this.submitOtherRowsIfChanged();
    }

    // Class method to loop through all other rows and submit if changed.
    submitOtherRowsIfChanged() {
        let currentController = this;

        Array.from(document.getElementsByClassName('expenses-row')).forEach(
            function(element) {
                let otherController = currentController.application.getControllerForElementAndIdentifier(element, "expense-entry");

                if (otherController != currentController) {
                    if (element.hidden) {
                        element.remove();
                    } else if (otherController.data.get('changePending') == '1') {
                        otherController.data.set('changePending', '0');
                        Rails.fire(otherController.element.firstElementChild, 'submit');
                    }
                }
            }
        );
    }

    // Event handler for when the user selects a particular expenses claim category
    categoryChange(event) {
        let dataset = event.srcElement.selectedOptions[0].dataset;
        this.vatTarget.value = dataset.vat;
        this.unitCostTarget.value = dataset.unitcost;
    }

    // Event handler for when the user changes a field that affects the total cost of the claim.
    recalcClaim(event) {
        console.log("Hello, recalcClaim!", this.element);
        this.totalCostTarget.value = (parseFloat(this.unitCostTarget.value) * parseInt(this.qtyTarget.value)).toFixed(2);
    }

    replaceRow(event) {
        console.log("Hello, submitSuccess!", this.element);

        let [data, status, xhr] = event.detail;

        console.log("And RoR returned", data);

        this.element.children[0].replaceWith(data.getElementsByTagName('form')[0]);
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
        this.element.setAttribute('hidden', 'true');
    }
}

