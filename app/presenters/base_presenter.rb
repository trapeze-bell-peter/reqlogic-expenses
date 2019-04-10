# frozen_string_literal: true

# Base class for presenters.  Provides access to URL helpers.
class BasePresenter
  # Stores a ref to the view context so we can use url_helpers etc
  # @api private
  # @param [ActiveView::Base] view
  def initialize(view)
    @view = view
  end

  attr_reader :view

  # Class method to map array of results to array of presenters
  # @param [Class] klass
  # @param [Array<GpImportResult>] results
  # @return [Array<klass>]
  def self.presenters(klass, results, view)
    results.map { |result| klass.new(result, view) }
  end

  # Given an hours field, round it to two decimal places.  If not, return 'N/A'
  # @param [Number] hours
  def format_hours_field(hours)
    hours&.round(2) || 'N/A'
  end
end
