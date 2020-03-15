

import ExpenseClaims from './expense_claims.svelte';
import CategoriesTable from './categories_table.svelte';
import CategoryForm from './CategoryForm.svelte';

let routes = {
    '/': ExpenseClaims,
    '/categories': CategoriesTable,
    '/categories/:category_id/edit': CategoryForm
};

export default routes;
