<script lang="ts">
    import * as jQuery from "jquery";
    import { createEventDispatcher, onMount } from 'svelte';

    import { ExpenseEntry } from "./ExpenseEntry";
    import { categoryStore, Category } from "./Category";
    import RailsFields from "./RailsFields.svelte";

    export let expenseEntry: ExpenseEntry;

    let unitCostValue: string = expenseEntry.unit_cost;

    onMount( () => {
        jQuery('[data-toggle="tooltip"]').tooltip();
    });

    function updateUnitCostValue(event) {
        expenseEntry.unit_cost = event.target.value;
        unitCostValue = expenseEntry.unit_cost;
    }

    const dispatch = createEventDispatcher();
    let sequenceField;

    function dispatchDraggable(draggable: boolean):void {
        dispatch('setdraggable', { sequenceField: sequenceField, draggable: draggable})
    }

    function ifFocusMovedToNewRow(event: FocusEvent):void {
        if (!event.currentTarget.contains(event.relatedTarget)) {
            expenseEntry.ifChangedSend();
        }
    }
</script>

<div class="form col-12" on:focusout={ifFocusMovedToNewRow}>
    <div class="form-row align-items-top">
        <div class="col-1">
            <input value={expenseEntry.sequence} class="form-control" readonly="readonly" type="text"
                   bind:this={sequenceField}
                   on:mousedown={ event => { dispatchDraggable(true ) } }
                   on:mouseup={ event => { dispatchDraggable(false) } } />
        </div>
        <div class="form-group col-1">
            <RailsFields inputType="date" expenseEntry={expenseEntry} field="date" />
        </div>
        <div class="form-group col-1">
            <RailsFields expenseEntry={expenseEntry} field="vat" let:feedbackDivId let:isInvalid>
                <select bind:value={expenseEntry.category_id} class="form-control form-select" class:is-invalid={isInvalid}
                        aria-describedby={feedbackDivId}>
                    {#each $categoryStore as category}
                        <option value={category.id}>
                            {category.name}
                        </option>
                    {/each}
                </select>
            </RailsFields>
        </div>
        <div class="form-group col-8">
            <RailsFields inputType="text" expenseEntry={expenseEntry} field="description"/>
        </div>
        <div class="form-group col-1">
            Actions
        </div>
    </div>

    <div class="form-row align-items-top justify-content-end">
        <div class="form-group col-1">
            <RailsFields inputType="text" expenseEntry={expenseEntry} field="project"/>
        </div>
        <div class="form-group col-1">
            <RailsFields expenseEntry={expenseEntry} field="vat" let:feedbackDivId let:isInvalid>
                <select bind:value={expenseEntry.vat} class="form-control form-select" class:is-invalid={isInvalid}
                        placeholder="VAT">
                    <option value="0">0</option>
                    <option value="20">20</option>
                </select>
            </RailsFields>
        </div>
        <div class="form-group col-1">
            <RailsFields inputType="number" expenseEntry={expenseEntry} field="qty"/>
        </div>
        <div class="form-group col-1">
            <RailsFields expenseEntry={expenseEntry} let:feedbackDivId let:isInvalid>
                <input bind:value={unitCostValue} on:change|stopPropagation={updateUnitCostValue}
                       class="form-control" placeholder="Unit Cost" class:is-invalid={isInvalid}
                       min="0.00" step="0.01" type="text" aria-describedby="unit-cost-feedback">
            </RailsFields>
        </div>
        <div class="form-group col-1">
            <input bind:value={expenseEntry.total} class="form-control" readonly="readonly" type="text">
        </div>
        <div class="form-group col-1">
            <a data-toggle="tooltip" data-placement="top" title="Insert empty row" class="expenses-action-icon"
               on:click={ () => dispatch("insertAt") }>
                <i class="fas fa-plus-square fa-2x expenses-action-icon" />
            </a>
            <a data-toggle="tooltip" data-placement="top" title="Delete row" class="expenses-action-icon"
               on:click={ () => dispatch("deleteAt") }>
                <i class="fas fa-trash fa-2x expenses-action-icon" />
            </a>
            <a data-toggle="tooltip" data-placement="top" title="Copy row to bottom" class="expenses-action-icon"
               on:click={ () => dispatch("copyToBottom") }>
                <i class="fas fa-copy fa-2x expenses-action-icon" />
            </a>
        </div>
    </div>
</div>

