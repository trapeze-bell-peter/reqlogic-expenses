

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

    // Removes those fields not required for sending to backend.
    toJSON(): string {
        const {...strippedExpenseEntry} = this;
        delete strippedExpenseEntry.id;
        return JSON.stringify(strippedExpenseEntry);
    }

    static async fetch(id: number): Promise<ExpenseEntry> {
        const res = await fetch(`${document.location.origin}/expense_entries/${id}`);
        const data = await res.json();

        return ExpenseEntry.from(data);
    }

    static async from(json) { return Object.assign(new ExpenseEntry(), json); }
}
