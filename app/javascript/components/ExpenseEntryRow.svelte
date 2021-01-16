<script lang="ts">
    import { onMount } from "svelte";

    import { ExpenseEntry } from "./ExpenseEntry";
    import { categoryStore, Category } from "./Category";

    export let expenseEntry: ExpenseEntry;
    let unitCostValue: string = expenseEntry.unit_cost;
    function updateUnitCostValue(event) {
        expenseEntry.unit_cost = event.target.value;
        unitCostValue = expenseEntry.unit_cost;
    }

    function expenseEntryMinusUnnecessaryFields() {
        const {...strippedExpenseEntry} = expenseEntry;
        delete strippedExpenseEntry.id;
        return strippedExpenseEntry;
    }
</script>

<div class="form col-12">
    <div class="form-row align-items-top">
        <div class="form-group col-1">
            <input bind:value={expenseEntry.sequence} class="form-control" readonly="readonly" type="text">
        </div>
        <div class="form-group col-1">
            <input bind:value={expenseEntry.date} class="form-control" placeholder="Date" type="date">
        </div>
        <div class="form-group col-1">
            <select bind:value={expenseEntry.category_id} class="form-control form-select">
                {#each $categoryStore as category}
                    <option value={category.id}>
                        {category.name}
                    </option>
                {/each}
            </select>
        </div>
        <div class="form-group col-8">
            <input bind:value={expenseEntry.description} class="form-control" placeholder="Description" type="text">
        </div>
        <div class="form-group col-1">
            Actions
        </div>
    </div>
    <div class="form-row align-items-top justify-content-end">
        <div class="form-group col-1">
            <input bind:value={expenseEntry.project} class="form-control" placeholder="Project" type="text">
        </div>
        <div class="form-group col-1">
            <select bind:value={expenseEntry.vat} class="form-control form-select" placeholder="VAT">
                <option value="0">0</option>
                <option value="20">20</option>
            </select>
        </div>
        <div class="form-group col-1">
            <input bind:value={expenseEntry.qty} class="form-control" placeholder="Qty" type="number">
        </div>
        <div class="form-group col-1">
            <input bind:value={unitCostValue} on:change|stopPropagation={updateUnitCostValue}
                   class="form-control" placeholder="Unit Cost" min="0.00" step="0.01" type="text">
        </div>
        <div class="form-group col-1">
            <input bind:value={expenseEntry.total} class="form-control" readonly="readonly" type="text">
        </div>
        <div class="form-group col-1">
            Actions
        </div>
    </div>
</div>
