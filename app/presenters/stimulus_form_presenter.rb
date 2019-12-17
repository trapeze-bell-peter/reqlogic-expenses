# frozen_string_literal: true

# Provides a standard way to generate forms and their fields within the app based on the fields name.
# Automatically adds the required definitions for Bootstrap and for Stimulus.js
class StimulusFormPresenter < BasePresenter
  # Factory to generate the form.  Use this, if we only need to create the form itself.
  # @param [ActionView::Template] view
  # @param [ActiveRecord] model
  # @param [Hash] form_args
  def self.form_factory(view, model, form_args, &block)
    form = self.new(view, model)
    form.create_form(form_args, block)
  end

  # Constructor
  # @param [ActiveView::Template] view
  def initialize(view, model)
    super(view, model)
  end

  attr_reader :model

  # Builds the form and yields back to ERB/HAML
  # @param [Hash] form_args
  def create_form(form_args, passed_block = nil)
    form_args[:model] = model
    form_args[:class] = 'form col-12'

    view.form_with form_args do |form|
      @form = form
      block_given? ? yield : passed_block.call(self)
    end
  end

  attr_reader :form
  delegate :label, to: :form

  # Entry point.  Given a type, and other parameters for the form_field, returns the appropriate HTML.  Note it
  # uses the name of the caller to infer which field we are configuring.
  #
  # @example
  #
  # def qty
  #   form_field :number_field
  # end
  #
  # In this case form_field will return:
  #
  # <input type='number_field' name='expense_entry_number_field' placeholder='Qtr' data-action='..' />
  def form_field(field_name, type, **other_args)
    view.capture do
      view.concat form.send(type, field_name, field_args(field_name, other_args))
      if model.errors[field_name].present?
        view.concat view.tag.small(model.errors[field_name].join(', '), class: 'text-danger')
      end
    end
  end

  # @param [String, Symbol] field_name
  def form_field_class(field_name = nil)
    field_name ||= caller_locations.first.label
    'form-control' + (model.errors[field_name].present? ? ' is-invalid' : '')
  end

  # @api private
  #
  # Builds the hash to be used for the field by combining the hash provided by the caller with some defaults using the
  # following rules:
  # * for the class and placeholder fields, if they are provided in the caller args, we use these, otherwise we
  #   provide defaults based on the field name
  # * for all other fields we simply add the string representation of the two fields.  In practice, this means that
  #   if one field is nil, we provide the value of the other field.
  #
  # @example
  #
  # field_args('date') =>
  # { class: :date, placeholder: 'Date',
  #   data: { action: 'focus->expense-claim#focusOnExpenseEntry change->expense-claim#changeToExpenseEntry' }
  # }
  #
  # field_args('date', class: :date_field, placeholder: 'My Special Date') =>
  # { class: :date, placeholder: 'My Special Date',
  #   data: { action: 'focus->expense-claim#focusOnExpenseEntry change->expense-claim#changeToExpenseEntry' }
  # }
  #
  # @param [String, Symbol] field_name
  # @param [Hash] other_args
  # @return [Hash]
  def field_args(field_name, other_args)
    self.default_field_hash(field_name).deep_merge!(other_args) do |key, this_val, other_val|
      case key
      when :class, :placeholder
        other_val
      else
        [this_val.to_s, other_val.to_s].join(' ')
      end
    end
  end
end