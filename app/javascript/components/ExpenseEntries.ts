import { ExpenseEntry } from "components/ExpenseEntry";

export class ExpenseEntries extends Array<ExpenseEntry> {
    sendIfChanged() {
        for(let expenseEntry of this) {
            expenseEntry.ifChangedSend()
        }
    }

    // Moves an expense row within the array.
    moveItem(moveFrom: number, moveTo: number): void {
        let itemBeingMoved = this.splice(moveFrom, 1)[0];
        this.splice(moveTo, 0, itemBeingMoved);

        const [from, to] = [moveFrom, moveTo].sort();
        for(let i = from; i<=to; i++) {
            this[i].sequence = i;
        }

        this.sendIfChanged();
    }

    insertEmptyAt(insertIndex: number): void {
        let newExpenseEntry = new ExpenseEntry();

        this.splice(insertIndex, 0, newExpenseEntry);

        for(let i=insertIndex; i<this.length; i++) {
            this[i].sequence = i;
        }
    }
}