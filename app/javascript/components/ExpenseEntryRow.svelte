<script lang="ts">
    import {StatusCodes} from "http-status-codes";
    import {onMount} from "svelte";

    import {ExpenseEntry} from "./ExpenseEntry";
    import {categoryStore, Category} from "./Category";
    import RailsFields from "./RailsFields.svelte";

    export let expenseEntry: ExpenseEntry;
    let originalExpenseEntry: ExpenseEntry = Object.assign({}, expenseEntry);
    let unitCostValue: string = expenseEntry.unit_cost;

    async function ifChangedSend() {
        let response = fetch(`${document.location.origin}/expense_entries/${expenseEntry.id}`, {
            method: 'PUT',
            headers: {'Content-Type': 'application/json;charset=utf-8'},
            body: JSON.stringify({expense_entry: expenseEntry.stripUnnecessaryFields()})
        }).then((response) => {
            switch (response.status) {
                case StatusCodes.OK:
                    originalExpenseEntry = Object.assign({}, expenseEntry);
                    expenseEntry.errors = undefined;
                    break;
                case StatusCodes.UNPROCESSABLE_ENTITY:
                    const errorPromise = response.json(); // Get JSON value from the response body
                    Promise.resolve(errorPromise).then(errorsAsJson => expenseEntry.errors = errorsAsJson['errors']);
                    break;
            }
        });
    }

    function updateUnitCostValue(event) {
        expenseEntry.unit_cost = event.target.value;
        unitCostValue = expenseEntry.unit_cost;
    }
</script>

<div class="form col-12" on:focusout={ifChangedSend}>
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
            <RailsFields expenseEntry={expenseEntry} field="project" let:feedbackDivId let:isInvalid>
                <input bind:value={expenseEntry.project} class="form-control" class:is-invalid={isInvalid}
                       placeholder="Project" type="text" aria-describedby={feedbackDivId}>
            </RailsFields>
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
                   class="form-control" placeholder="Unit Cost" min="0.00" step="0.01" type="text"
                   aria-describedby="unit-cost-feedback">
            <div id="unit-cost-feedback" class="invalid-feedback">Not valid :(</div>
        </div>
        <div class="form-group col-1">
            <input bind:value={expenseEntry.total} class="form-control" readonly="readonly" type="text">
        </div>
        <div class="form-group col-1">
            Actions
        </div>
    </div>
</div>
