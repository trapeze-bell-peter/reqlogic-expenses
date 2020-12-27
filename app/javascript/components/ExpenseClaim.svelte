<script lang="ts">
    // Used by the router to pass in parameters from the call - here the id of expense claim.
    export let params = {}

    // on unmount we need to re-submit all.

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
