# frozen_string_literal: true

# Presenter class for the projects bookings table - presenter is used in a number of different places.
class CategoryPresenter < BasePresenter
  # Initializer
  #
  # @api public
  # @param [ActiveView::Template] view
  def initialize(view)
    super(view)
  end

  def options_for_select
    view.options_for_select()

  end
end