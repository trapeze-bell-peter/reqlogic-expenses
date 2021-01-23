<script lang="ts">
    import {ExpenseEntry} from "./ExpenseEntry";

    export let field: string;
    export let expenseEntry: ExpenseEntry;

    let isInvalid;
    $: isInvalid = expenseEntry.errorsPresent(field);
    
    let feedbackDivId = `${field}-feedback-${expenseEntry.id}}`;
</script>

<slot feedbackDivId={feedbackDivId} isInvalid={isInvalid}></slot>

<div id={feedbackDivId} class="invalid-feedback">
    {expenseEntry.errorsString(field)}
</div>