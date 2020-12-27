// Configures the routing so we can run the expense app as a SPA.

import ExpenseClaims from './ExpenseClaims.svelte';
import ExpenseClaim from './ExpenseClaim.svelte';
import CategoriesTable from "./categories_table.svelte";

const routes = {
    '/': ExpenseClaims,
    '/ExpenseClaim/:id': ExpenseClaim,
    '/categories': CategoriesTable
};

export default routes;
