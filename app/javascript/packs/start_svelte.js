/* eslint no-console: 0 */

// This file provides the mechanism to load the Svelte app itself.  Invoked from application.html.erb
import 'popper.js';
import 'bootstrap';
import '@fortawesome/fontawesome-free/js/all';

import App from "../components/App.svelte";

document.addEventListener('DOMContentLoaded', () => {
  const app = new App({
    target: document.body,
    props: {}
  });

  window.app = app;
});
