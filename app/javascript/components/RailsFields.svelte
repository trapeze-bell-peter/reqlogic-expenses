<script lang="ts">
    import humanize from "string-humanize";
    import { onMount } from "svelte";

    import {ExpenseEntry} from "./ExpenseEntry";

    export let inputType: string;
    export let field: string;
    export let expenseEntry: ExpenseEntry;

    let isInvalid;
    $: isInvalid = expenseEntry.errorsPresent(field);

    let id = `${field}-${expenseEntry.id}}`;
    let feedbackDivId = `${field}-feedback-${expenseEntry.id}}`;

    onMount( () => {
        if (inputType!==undefined) {
            document.getElementById(id).setAttribute('type', inputType)
        }
    });
</script>

{#if inputType!==undefined}
    <input id={id} bind:value={expenseEntry[field]} class="form-control" class:is-invalid={isInvalid}
           placeholder={humanize(field)} type="text" aria-describedby={feedbackDivId}>
{:else}
    <slot feedbackDivId={feedbackDivId} isInvalid={isInvalid}></slot>
{/if}

<div id={feedbackDivId} class="invalid-feedback">
    {expenseEntry.errorsString(field)}
</div>