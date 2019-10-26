# frozen_string_literal: true

# Base class for presenters.  Provides access to URL helpers.
class BasePresenter
  # Stores a ref to the view context so we can use url_helpers etc
  # @api private
  # @param [ActiveView::Base] view
  # @param [ActiveModel] model
  def initialize(view, model)
    @view = view
    @model = model
  end

  attr_reader :view
  attr_reader :model
end
