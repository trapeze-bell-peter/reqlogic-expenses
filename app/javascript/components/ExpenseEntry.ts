

import { Category, categories } from './Category';
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

    set category_id(id: bigint) {
        this.category = Category.find(id);
    }
}
