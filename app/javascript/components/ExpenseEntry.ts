

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
}
