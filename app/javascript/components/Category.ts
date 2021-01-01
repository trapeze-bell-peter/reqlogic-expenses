console.log('Hello world from category.ts');

import { Readable, readable } from 'svelte/store';

export class Category {
    id: number;
    name: string;
    vat: number;
    unit_cost_pence: number;
    unit_cost_currency: string;
    url: string;

    formatted_unit_cost() : string {
        if (this.unit_cost_pence==undefined) {
            return 'N/A';
        } else {
            let unit_cost = Number(this.unit_cost_pence) / 100.0;
            return unit_cost.toLocaleString(undefined, {style: "currency", currency: this.unit_cost_currency});
        }
    }

    get unit_cost() { return Number(this.unit_cost_pence) / 100.0 }
    set unit_cost(val) { this.unit_cost_pence = Math.trunc(val * 100) }

    static async fetchCategories() {
        let res = await fetch(`${document.location.origin}/categories.json`);
        let data = await res.json();

        return data.map(categoryInJson => Category.from(categoryInJson));
    }

    // Create an object from the JSON sent by the backend
    static from(json){
        return Object.assign(new Category(), json);
    }

    static find(id: bigint) : Category {
        return categories.find(category => category.id == id);
    }
}

export let categories: Readable<any[]> = readable([], set => { Category.fetchCategories().then(set) }) ;
