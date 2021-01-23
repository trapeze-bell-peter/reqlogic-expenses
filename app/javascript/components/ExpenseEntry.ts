

import { Category } from './Category';
import * as currency from 'currency.js';

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

    _unit_cost: currency;
    set unit_cost(value: string) {
        this._unit_cost = currency(value, {symbol: "£"});
    }
    get unit_cost(): string {
        return this._unit_cost!=undefined ? this._unit_cost.format() : "";
    }

    get total(): string {
        const c = currency(this.unit_cost, {symbol: "£"});
        return c.multiply(this.qty).format();
    }

    errorsPresent(field: string):boolean {
        return this.errors!==undefined && this.errors[field]!==undefined;
    }
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
        return strippedExpenseEntry;
    }

    static async fetch(id: number): Promise<ExpenseEntry> {
        const res = await fetch(`${document.location.origin}/expense_entries/${id}`);
        const data = await res.json();

        return ExpenseEntry.from(data);
    }

    static async from(json) { return Object.assign(new ExpenseEntry(), json); }
}
