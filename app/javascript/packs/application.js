// This file provides the standard Rails Javascript items.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start();
Turbolinks.start();
ActiveStorage.start();
