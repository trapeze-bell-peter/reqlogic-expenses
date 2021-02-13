

import { Category } from './Category';
import * as currency from 'currency.js';
import {StatusCodes} from "http-status-codes";

export class ExpenseEntry {
    id :number;
    date: Date;
    sequence: number;
    category: Category;
    description: string;
    project: string;
    vat: number;
    qty: number;
    errors: object;

    private originalExpenseEntry : ExpenseEntry = undefined;

    // Internal member used to hold the unit cost including its currency and any formatting.
    private _unit_cost: currency;

    // accessor used to set the unit cost.  It is passed a string which can include the currency symbol.
    set unit_cost(value: string) {
        this._unit_cost = currency(value, {symbol: "£"});
    }

    // Returns the unit cost as a string formatted according to the locale.
    get unit_cost(): string {
        return this._unit_cost!=undefined ? this._unit_cost.format() : "";
    }

    // Returns the total amount that this expense entry represents based on the units and the unit cost.  The
    // amount is formatted to show the currency.
    get total(): string {
        const c = currency(this.unit_cost, {symbol: "£"});
        return c.multiply(this.qty).format();
    }

    checkpoint() {
        this.originalExpenseEntry = Object.assign({}, this);
        this.errors = undefined;
    }

    // Returns a flag indicating whether an error has been flagged on the field.
    errorsPresent(field: string):boolean {
        return this.errors!==undefined && this.errors[field]!==undefined;
    }

    // Returns a string flagging all errors on a field as stored in the errors property.
    errorsString(field: string): string {
        return this.errorsPresent(field) ? this.errors[field].join(", ") : "";
    }

    // Removes those fields not required for sending to backend.
    stripUnnecessaryFields() {
        let {...strippedExpenseEntry} = this;

        strippedExpenseEntry.unit_cost = this.unit_cost;

        delete strippedExpenseEntry.id;
        delete strippedExpenseEntry._unit_cost;
        delete strippedExpenseEntry.errors;
        delete strippedExpenseEntry.originalExpenseEntry;

        for (const [key, val] of Object.entries(strippedExpenseEntry)) {
            console.log(`${key} is ${val}`);

            if (val == this.originalExpenseEntry[key]) {
                delete strippedExpenseEntry[val];
            }
        }

        return (Object.keys(strippedExpenseEntry).length > 0) ? strippedExpenseEntry : null;
    }

    // Sends the object to the backend.  Checks the return and sets the `errors` property accordingly.
    async sendWhatsChanged() {
        const strippedExpenseEntry = this.stripUnnecessaryFields();

        // If nothing has changed, then exit early.
        if (strippedExpenseEntry == null) return;

        fetch(this.url, {
            method: 'PUT',
            headers: {'Content-Type': 'application/json;charset=utf-8'},
            body: JSON.stringify({ expense_entry: this.stripUnnecessaryFields()} )
        }).then((response) => {
            switch (response.status) {
                case StatusCodes.OK:
                    this.checkpoint();
                    break;
                case StatusCodes.UNPROCESSABLE_ENTITY:
                    const errorPromise = response.json(); // Get JSON value from the response body
                    Promise.resolve(errorPromise).then(errorsAsJson => this.errors = errorsAsJson['errors']);
                    break;
            }
        });
    }

    // Given an id for an ExpenseEntry, retrieves the ExpenseEntry from the backend and creates the corresponding
    // object.
    static async fetchExpenseEntry(id: number): Promise<ExpenseEntry> {
        return await fetch(ExpenseEntry.url(id)).then(response => {
            return response.json();
        }).then( jsonData => {
            let fetchedExpenseEntry = new ExpenseEntry();
            Object.assign(fetchedExpenseEntry, jsonData);
            fetchedExpenseEntry.originalExpenseEntry = Object.assign({}, fetchedExpenseEntry);
            return fetchedExpenseEntry;
        });
    }

    // Builds a string of the current object's URL on the backend.
    get url(): string {
        return ExpenseEntry.url(this.id);
    }

    // Builds a string of an expense entry given its id.
    static url(id: number): string {
        return `${document.location.origin}/expense_entries/${id}`;
    }

}
