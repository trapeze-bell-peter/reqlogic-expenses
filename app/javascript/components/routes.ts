// Configures the routing so we can run the expense app as a SPA.

import ExpenseClaims from './ExpenseClaims.svelte';
import ExpenseClaim from './ExpenseClaim.svelte';
import CategoriesTable from "./CategoriesTable.svelte";

const routes = {
    '/': ExpenseClaims,
    '/ExpenseClaim/:id': ExpenseClaim,
    '/Categories': CategoriesTable
};

export default routes;
