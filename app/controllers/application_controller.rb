# frozen_string_literal: true

# Top level controller.  Ensures all user interactions are authenticated.
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
end
