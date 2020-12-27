<script lang="ts">
    // Used by the router to pass in parameters from the call - here the id of expense claim.
    export let params = {}
    export let expense_claim_id = parseInt(params.id);

    // on unmount we need to re-submit all.
    import { onMount } from 'svelte';

    export let description;
    export let claimDate;

    onMount( async () => {
        let res = await fetch(`${document.location.origin}/expense_claims/${expense_claim_id}.json`);
        let data = await res.json();

        description = data.description;
        claimDate = data.claim_date;
    });
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
            <input bind:value={description} class="form-control" type="text" id="expense-claim-description" placeholder="Enter Description">
        </div>
    </div>
    <div class="form-group row">
        <label class="col-1 col-form-label" for="expense_claim_date">Date</label>
        <div class="col-2">
            <input bind:value={claimDate} class="form-control" type="date" placeholder="Claim date" id="expense_claim_claim_date">
        </div>
    </div>
</div>
