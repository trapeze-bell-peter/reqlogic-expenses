<script lang="ts">
    // on unmount we need to re-submit all.
    import { onMount } from 'svelte';

    import ExpenseEntryRow from './ExpenseEntryRow.svelte';

    // Used by the router to pass in parameters from the call - here the id of expense claim.
    export let params = {}
    export let expense_claim_id = parseInt(params.id);
    export let description;
    export let claimDate;

    let url = `${document.location.origin}/expense_claims/${expense_claim_id}.json`;

    onMount( async () => {
        let res = await fetch(url);
        let data = await res.json();

        description = data.description;
        claimDate = data.claim_date;
    });

    async function sendData() {
        const res = await fetch(url, { method: 'PUT',
                                       body: JSON.stringify( { expense_claim: { description, claimDate } })
        });
        const json = await res.json();
        result = JSON.stringify(json);
    }
</script>

<div id="expense-claim">
    <div id="expense-claim-actions">
        <a href="#/download-excel.svelte">
            <i class='fas fa-file-excel fa-2x'></i>
        </a>
        <a href="#/print.svelte">
            <i class='fas fa-print fa-2x'></i>
        </a>
    </div>
</div>

<div id="expense-claim-key-data">
    <div class="form-group row">
        <label class="col-1 col-form-label" for="expense-claim-description">Description</label>
        <div class="col-6">
            <input bind:value={description} on:change={sendData} class="form-control" type="text" id="expense-claim-description" placeholder="Enter Description">
        </div>
    </div>
    <div class="form-group row">
        <label class="col-1 col-form-label" for="expense_claim_date">Date</label>
        <div class="col-2">
            <input bind:value={claimDate} class="form-control" type="date" placeholder="Claim date" id="expense_claim_claim_date">
        </div>
    </div>
</div>

<div id="expenses-claim-table">
    <div id="expense-entries-header">
        <div class="form-row">
            <div class="form-group col-1">Seq</div>
            <div class="form-group col-2">Date</div>
            <div class="form-group col-2">Category</div>
            <div class="form-group col-1">Description</div>
            <div class="form-group col-1">Project Code</div>
            <div class="form-group col-1">VAT</div>
            <div class="form-group col-1">Qty</div>
            <div class="form-group col-1">Unit Cost</div>
            <div class="form-group col-1">Total Cost</div>
            <div class="form-group col-1">Actions</div>
        </div>
    </div>

    <ExpenseEntryRow id={1}/>
</div>
