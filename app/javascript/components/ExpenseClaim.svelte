<script lang="ts">
    import { onMount } from "svelte";
    import { StatusCodes } from "http-status-codes";

    import { ExpenseEntry } from "./ExpenseEntry";
    import ExpenseEntryTable from "./ExpenseEntryTable.svelte";
    import {ExpenseEntries} from "components/ExpenseEntries";

    let expenseEntries: ExpenseEntries;

    // Used by the router to pass in parameters from the call - here the id of expense claim.
    export let params = {}
    let expense_claim_id = parseInt(params.id);

    let description;
    let claimDate;

    let url = `${document.location.origin}/expense_claims/${expense_claim_id}`;

    onMount( async () => {
        let res = await fetch(url).then(response => {
            if (response.status == StatusCodes.OK) {
                return response.json();
            }
        }).then( data => {
            description = data.description;
            claimDate = data.claim_date;
            expenseEntries = new ExpenseEntries();

            for(let expenseEntryData of data.expense_entries) {
                let newExpenseEntry = Object.assign(new ExpenseEntry(), expenseEntryData)
                expenseEntries.push(newExpenseEntry);
            }
            return expenseEntries;
        });
    });

    async function sendData() {
        const res = await fetch(url, { method: 'PUT',
            body: JSON.stringify( { expense_claim: { description, claimDate } })
        });
        const json = await res.json();
        JSON.stringify(json);
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

<div id="expense-claim-key-data" class="form col-12">
    <div class="form-group row">
        <label class="col-1 col-form-label" for="expense-claim-description">Description</label>
        <div class="col-6">
            <input bind:value={description} on:change={sendData} class="form-control" type="text" id="expense-claim-description" placeholder="Enter Description">
        </div>
    </div>
    <div class="form-group row">
        <label class="col-1 col-form-label" for="expense_claim_claim_date">Date</label>
        <div class="col-2">
            <input bind:value={claimDate} class="form-control" type="date" placeholder="Claim date" id="expense_claim_claim_date">
        </div>
    </div>
</div>

<ExpenseEntryTable expenseEntries={expenseEntries} />
