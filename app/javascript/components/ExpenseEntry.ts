

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

    unit_cost: string;
    unit_cost_currency_symbol: string;
    get total(): string { return currency(this.unit_cost).multiply(this.qty).format({symbol: this.unit_cost_currency_symbol}); }

    static async fetch(id: number): Promise<ExpenseEntry> {
        const res = await fetch(`${document.location.origin}/expense_entries/${id}`);
        const data = await res.json();

        return ExpenseEntry.from(data);
    }

    static async from(json) { return Object.assign(new ExpenseEntry(), json); }
}
