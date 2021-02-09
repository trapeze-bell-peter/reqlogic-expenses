import { ExpenseEntry } from "components/ExpenseEntry";

export class ExpenseEntries extends Array<ExpenseEntry> {

    moveItem(moveFrom: number, moveTo: number) {
        let itemBeingMoved = this.splice(moveTo, 1)[0];
        this.splice(moveTo, 0, itemBeingMoved);

        const [from, to] = [moveFrom, moveTo].sort();
        for(let i = from; i<=to; i++) {
            this[i].sequence = i;
            this[i].send();
        }
    }
}