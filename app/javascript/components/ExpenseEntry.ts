

import { Category } from './Category';
import 'currency.js';

export class ExpenseEntry {
    id :number;
    date: Date;
    sequence: number;
    category: Category;
    description: string;
    project: string;
    vat: number;
    qty: bigint;
    unit_cost: currency;

    get total(): string { return this.unit_cost.multiply(this.qty).format() };
}
