<script lang="ts">
    import { Category } from './Category';
    import { onMount } from 'svelte';

    // parse the route
    export let params = {};
    let category_id = parseInt(params.category_id);

/*    if (false) {
        // first time we load this component, make sure the categories store has been fetched from the backend
        onMount( async () => {
            if ($categories == null) {
                await fetchCategories();
                console.log($categories.get(category_id));
            }
        });

        // bindings
        let category;
        $: category  = ($categories != null) ? $categories.get(category_id) : null;
    }

    // event handlers
    async function handleSubmit() {
        let response = await fetch(category.url, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json;charset=utf-8' },
            body: JSON.stringify(category)
        });
    }*/
</script>

{ #if category != null }
    <h1>{category.name}</h1>
    <form on:submit|preventDefault="{handleSubmit}">
        <div class="form-row">
            <div class="form-group col-md-4">
                <label for="name">Name</label>
                <input type="text" class="form-control" name="category[{category_id}][name]" value="{category.name}" required="true"/>
            </div>

            <div class="form-group col-md-2">
                <label for="vat">VAT</label>
                <input type="number" min="0" max="100" name="category[{category_id}][vat]" value="{category.vat}" required="true"/>
            </div>

            <div class="form-group col-md-2">
                {category.unit_cost}
                <label for="unit_cost">Unit Cost</label>
                <input type="number" min="0.01" step="0.01" name="category[{category_id}][unit_cost]" value="{category.unit_cost}"/>
            </div>
        </div>

        <div class="actions">
            <input type="submit" class="btn btn-primary">
        </div>
    </form>
{ /if }

