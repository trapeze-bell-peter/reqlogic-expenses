<script lang="ts">
    import {onMount} from 'svelte';

    import { link } from 'svelte-spa-router';
    import routes from './routes';

    import ExpenseClaim from "./ExpenseClaim.svelte";

    export let expenseClaims = [];

    onMount(async () => {
        const res = await fetch(`${document.location.origin}/expense_claims.json`);
        expenseClaims = await res.json();
    });
</script>

<style>

</style>

<h1>Expense Claims</h1>

<div id='expense-claim-index-actions'>
    <a href="#/expense_claims.svelte">
        <i class='fas fa-plus-square fa-2x'></i>
    </a>
    <span>
    <button class='expenses-button'>
      <i class='fas fa-file-upload fa-2x'></i>
    </button>
  </span>
</div>

<br>

<table class='table table-hover'>
    <thead>
        <tr>
            <th>Description</th>
            <th>Claim Date</th>
            <th>Earliest Date</th>
            <th>Latest Date</th>
            <th>Total</th>
            <th colspan='3' scope='col'></th>
        </tr>
    </thead>

    <tbody>
        {#each expenseClaims as expenseClaim}
            <tr>
                <td>
                    <a use:link class="nav-link" href={`/ExpenseClaim/${expenseClaim.id}`}>
                        {expenseClaim.description}
                    </a>
                </td>
                <td>{expenseClaim.claim_date}</td>
                <td>{expenseClaim.first_date}</td>
                <td>{expenseClaim.last_date}</td>
                <td>{expenseClaim.total}</td>
                <td></td>
            </tr>
        {/each}
    </tbody>
</table>
