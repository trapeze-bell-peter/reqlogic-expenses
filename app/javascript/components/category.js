export default class Category {
    id; // integer
    name; // string
    vat; // float
    unit_cost_pence; // integer
    unit_cost_currency; // string
    url; // string

    formatted_unit_cost() {
        if (this.unit_cost_pence==undefined) {
            return 'N/A';
        } else {
            let unit_cost = this.unit_cost_pence / 100.0;
            return unit_cost.toLocaleString(undefined, {style: "currency", currency: this.unit_cost_currency});
        }
    }

    get unit_cost() { return this.unit_cost_pence / 100.0 }
    set unit_cost(val) { Math.trunc(this.unit_cost_pence = val * 100) }

    // Create an object from the JSON sent by the backend
    static from(json){
        return Object.assign(new Category(), json);
    }
}
