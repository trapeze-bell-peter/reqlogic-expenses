# Rails project using Typescript, Svelte and Bootstrap

## Create the new project

```
rails new typescript_demo                                            # Setup a new rails project
cd typescript_demo/
bundle install                                                       # Install the standard rails GEMs required for a Rails app
```

## Generate a Simple Controller and Index page to Server the Svelte App 

```
rails generate controller home index                                 # Create a simple framework
```


## Install Typescript, Svelte, Bootstrap and Fontawesome

```
bundle exec rails webpacker:install:typescript                       # Add typescript support to Webpacker
rails webpacker:install:svelte                                       # Add support for Svelte for Webpacker
yarn add bootstrap popper.js@^1.16.1 @fortawesome/fontawesome-free   # Add support for Bootstrap 
```

Add the following to the `app/javascript/packs/application.html.erb`:

```javascript
import 'bootstrap';
import '@fortawesome/fontawesome-free/js/all';
```

# Now start creating the constituent parts:

Add the following to `application.html.erb`:
```erbruby
  <body>
    <%= javascript_pack_tag 'hello_svelte' %>
  </body>
```

Create the file `app/javascript/components/Category.ts`:

```typescript
console.log('Hello world from Category.ts');

export default class Category {
    member: bigint;
}
```

Add the following to `hello_svelte.ts`:
```typescript
import Category from "components/category";

let category = new Category();
```

Add the following to `app.svelte`:
```sveltehtml
<script lang="ts">
    import Category from "./components/category";

    let category = new Category();

    export let name;
</script>
```


