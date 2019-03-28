import { Controller } from "stimulus";
import Rails from "rails-ujs";

export default class ExpenseEntryController extends Controller {
    static targets = [];

    connect() {
        console.log('hello from ExpenseEntryController');
    }

    // The backend serves up a div row with the details.
    replaceRow(event) {
        let [data, status, xhr] = event.detail;
        this.element.children[0].replaceWith(data.getElementsByTagName('form')[0]);
    }

    // Event handler for when the user presses the insert on an expesne row.
    insertRow(event) {
        event.preventDefault();

        fetch(event.currentTarget.href)
            .then( response => { return response.text(); })
            .then( html => { this.element.insertAdjacentHTML('afterend', html); });
    }

    // Event handler for when the user presses the delete on an expense row.  For now we simply mark it as
    // hidden.  We remove
    deleteRow(event) {
        this.element.hidden = 'true';
    }
}

