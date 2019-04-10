// Load all the controllers within this directory and all subdirectories. 
// Controller files must be named *_controller.js.

import Rails from "rails-ujs";
Rails.start();

import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";

const application = Application.start();
const context = require.context("controllers", true, /_controller\.js$/);
application.load(definitionsFromContext(context));
