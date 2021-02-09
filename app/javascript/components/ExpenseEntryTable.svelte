<script lang="ts">
    import { flip } from 'svelte/animate';

    import ExpenseEntryRow from "./ExpenseEntryRow.svelte";
    import RailsFields from "./RailsFields.svelte";

    export let expenseEntries;

    let hovering = false;

    // Event handler for when we receive a mousedown or mouseup event on the sequence field.
    function setDraggable(event: CustomEvent) {
        event.detail.sequenceField.closest('.expense-row').setAttribute('draggable', event.detail.draggable);
    }

    function drop(DragEvent: event, insertIndex: number) {
        event.dataTransfer.dropEffect = 'move';
        const draggedIndex = parseInt(event.dataTransfer.getData("text/plain"));
        const reorderedExpenseEntries = expenseEntries;

        let expenseRowBeingDragged = reorderedExpenseEntries.splice(draggedIndex, 1)[0];
        reorderedExpenseEntries.splice(insertIndex, 0, expenseRowBeingDragged);

        const [from, to] = [insertIndex, draggedIndex].sort();
        for(let i = from; i<=to; i++) {
            reorderedExpenseEntries[i].sequence = i;
            reorderedExpenseEntries[i].send();
        }

        expenseEntries = reorderedExpenseEntries;
        hovering = null;
    }

    function dragStart(DragEvent: event, i) {
        event.dataTransfer.effectAllowed = 'move';
        event.dataTransfer.dropEffect = 'move';
        const draggedIndex = i;
        event.dataTransfer.setData('text/plain', draggedIndex);
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

    {#if expenseEntries}
        {#each expenseEntries as expenseEntry, index  (expenseEntry.id)}
            <div class="expense-row"
                 animate:flip
                 draggable="false"
                 on:dragstart={event => dragStart(event, index)}
                 on:drop|preventDefault={event => drop(event, index)}
                 ondragover="return false"
                 on:dragenter={() => hovering = index}
                 class:is-active={hovering === index}>
                 <ExpenseEntryRow bind:expenseEntry on:setdraggable={ event => setDraggable(event) }/>
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