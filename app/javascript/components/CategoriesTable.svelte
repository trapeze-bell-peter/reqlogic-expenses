<script lang="ts">
    import { link } from 'svelte-spa-router';
    import { Category } from './Category';

    let categoryList = Category.fetchCategories();
    let categories;
</script>

<h1>Categories</h1>

<table class="table table-hover">
    <thead>
        <tr>
            <th scope="col">Name</th>
            <th scope="col">VAT</th>
            <th scope="col">Unit Cost</th>
            <th scope="col" colspan="3"></th>
        </tr>
    </thead>

    <tbody>
        {#await categoryList}
            <tr>
                ... Loading
            </tr>
        {:then categories}
            {#each categories as category }
                <tr>
                    <td>{category.name}</td>
                    <td>{category.vat}</td>
                    <td>{category.formatted_unit_cost()}</td>
                    <td>Show</td>
                    <td><a href="/categories/{category.id}/edit" use:link>Edit</a></td>
                    <td>Destroy</td>
                </tr>
            {/each}
        {/await}
    </tbody>
</table>

<br>

New Category

