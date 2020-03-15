<script>
  import Router from 'svelte-spa-router';

  // Import the "link" action and the methods to control history programmatically from the same module, as well as the location store
  import {link, active, push, pop, replace, location, querystring} from 'svelte-spa-router';

  // Import the list of routes
  import routes from './routes';
</script>

<style>

</style>

<!-- Navigation -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark static-top">
  <div class="container-fluid">
    <p class="navbar-brand">TGUK Expenses App</p>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarResponsive" aria-controls="navbarResponsive" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarResponsive">
      <ul class="navbar-nav ml-auto">
        Back [Slot]
        <li class="nav-item">
          <a href="/" use:link class="nav-link">Expense Claims</a>
        </li>
        <li class="nav-item">
          <a href="/categories" use:link class="nav-link">Categories</a>
        </li>
      </ul>
    </div>
  </div>
</nav>

<Router {routes}/>