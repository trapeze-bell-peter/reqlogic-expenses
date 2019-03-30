import { Controller } from "stimulus";

export default class ExpenseEntryController extends Controller {
    static targets = [];

    connect() {
    }

    dragstart(event) {
        console.log('dragstart for', this.element);
        event.dataTransfer.effectAllowed = "move";
        event.dataTransfer.setData("text/plain", this.element.id);
    }

    dragenter(event) {
        event.preventDefault()
    }

    dragover(event) {
        console.log('drageover for', event);
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

    // The backend serves up a div row with the details.
    replaceRow(event) {
        console.log('replaceRow invoked');
        let [data, status, xhr] = event.detail;
        this.element.replaceWith(data.getElementsByClassName('expenses-row')[0]);
    }

    // Event handler for when the user presses the insert on an expesne row.
    insertRow(event) {
        event.preventDefault();
        this.element.insertAdjacentElement('afterend', this.createEmptyRow());
    }

    // Event handler to copy row.  It does this by fetching an empty row from the backend and then copying the
    // input elements across.
    copyRow(event) {
        event.preventDefault();

        let parentDiv = this.element.closest('div#expenses-entry-table');
        let newRow = this.createEmptyRow();

        this.copyInputElements(newRow);

        parentDiv.appendChild(newRow);
    }

    // Get the empty row out of the template, clone it, and give it and id of the current time.
    createEmptyRow() {
        let template = document.getElementById('expense-entry-empty-row');
        let new_row = template.content.getElementById('expense-entry-empty-row').cloneNode(true);
        new_row.id = `expense-entry-${Date.now()}`;
        return new_row;
    }

    // Given the new row, copy all inputs across from the current row.
    copyInputElements(newRow) {
        for(let elementType of ['input', 'select']) {
            let elements = newRow.getElementsByTagName(elementType);
            for(let i=0; i< elements.length; i++) {
                if (elements[i].type!=='hidden') {
                    elements[i].value = this.element.querySelector(`${elementType}#${elements[i].id}`).value
                }
            }
        }
    }

    // Event handler for when the user presses the delete on an expense row.  For now we simply mark it as
    // hidden.  We remove
    deleteRow(event) {
        this.element.hidden = 'true';
    }
}

