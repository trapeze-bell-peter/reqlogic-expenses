import { writable } from 'svelte/store';
import Category from './category';

export let categories = writable( null );

export async function fetchCategories() {
    let res = await fetch(`${document.location.origin}/categories.json`);
    let data = await res.json();

    let categoriesArray = data.map( categoryInJson => Category.from(categoryInJson));

    let categoriesList = new Map(categoriesArray.map(category => [category.id, category]));

    console.log(categoriesList);
    categories.set(categoriesList);

    return await Promise.resolve(categoriesArray);
}
