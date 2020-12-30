<script lang="ts">
    import { onMount } from "svelte";

    import ExpenseEntry from "./ExpenseEntry";
    import {categories, Category} from "./Category";

    export let id: number;
    export let expenseEntry: ExpenseEntry;

    // first time we load this component, make sure the categories store has been fetched from the backend

    onMount( async () => {
        let res = await fetch(`${document.location.origin}/expense_entries/${id}`);
        expenseEntry = await res.json();
    });
</script>


<div class="form col-12">
    {#if expenseEntry}
        <div class="form-row align-items-top">
            <div class="form-group col-1">
                <input bind:value={expenseEntry.sequence} class="form-control" readonly="readonly" type="text">
            </div>
            <div class="form-group col-2">
                <input bind:value={expenseEntry.date} class="form-control" placeholder="Date" type="date">
            </div>
            <div class="form-group col-2">
                <select bind:value={expenseEntry.category.id} >
                    {#each categories as category}
                        <option value={category.id}>
                            {category.name}
                        </option>
                    {/each}
                </select>
            </div>
        </div>
    {:else}
        Loading
    {/if}
</div>
