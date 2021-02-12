<script lang="ts">
    import { flip } from 'svelte/animate';

    import ExpenseEntryRow from "./ExpenseEntryRow.svelte";
    import RailsFields from "./RailsFields.svelte";
    import  { ExpenseEntries } from "./ExpenseEntries";
    import { ExpenseEntry } from "./ExpenseEntry";

    export let expenseEntries: ExpenseEntries;

    let hovering = false;

    // Event handler for when we receive a mousedown or mouseup event on the sequence field.
    function setDraggable(event: CustomEvent) {
        event.detail.sequenceField.closest('.expense-row').setAttribute('draggable', event.detail.draggable);
    }

    function drop(event: DragEvent, insertIndex: number) {
        event.dataTransfer.dropEffect = 'move';
        const draggedIndex = parseInt(event.dataTransfer.getData("text/plain"));

        const reorderedExpenseEntries = expenseEntries;
        reorderedExpenseEntries.moveItem(draggedIndex, insertIndex);
        expenseEntries = reorderedExpenseEntries;

        hovering = null;
    }

    function dragStart(event: DragEvent, i: number): void {
        event.dataTransfer.effectAllowed = 'move';
        event.dataTransfer.dropEffect = 'move';
        const draggedIndex = i;
        event.dataTransfer.setData('text/plain', String(draggedIndex));
    }

    function insertAt(insertIndex: number): void {
        let newExpenseEntry = new ExpenseEntry();

        const reorderedEntryExpenses = expenseEntries;
        reorderedEntryExpenses.splice(insertIndex, 0, newExpenseEntry);
        expenseEntries = reorderedEntryExpenses;
    }
</script>

<div class="expenses-claim-table .list-group">
    <div class="form col-12">
        <div id="expense-entries-header" class="form-row">
            <div class="form-group col-1">Seq</div>
            <div class="form-group col-1">Date</div>
            <div class="form-group col-1">Category</div>
            <div class="form-group col-3">Description</div>
            <div class="form-group col-1">Project Code</div>
            <div class="form-group col-1">VAT</div>
            <div class="form-group col-1">Qty</div>
            <div class="form-group col-1">Unit Cost</div>
            <div class="form-group col-1">Total Cost</div>
            <div class="form-group col-1">Actions</div>
        </div>
    </div>

    { @debug(expenseEntries) }

    { #if expenseEntries !== undefined }
        {#each expenseEntries as expenseEntry, index  (expenseEntry.id)}
            <div class="expense-row"
                 animate:flip
                 draggable="false"
                 on:dragstart={event => dragStart(event, index)}
                 on:drop|preventDefault={event => drop(event, index)}
                 ondragover="return false"
                 on:dragenter={() => hovering = index}
                 class:is-active={hovering === index}>
                 <ExpenseEntryRow bind:expenseEntry
                                  on:setdraggable={ event => setDraggable(event) }
                                  on:insertAt={ () => insertAt(index+1) } />
            </div>
        {/each}
    {:else}
        ... Loading
    {/if}
</div>

<style lang="scss">
    .expenses-claim-table {
    }

    .expense-row {
        display: block;
    }

    .expense-row:not(:last-child) {

    }

    .expense-row.is-active {
        background-color: #3273dc;
        color: #fff;
    }
</style>