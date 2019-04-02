# frozen_string_literal: true

# Provides a standard way to generate form fields within the app based on the fields name.  Automatically adds
# the required definitions for Bootstrap and for Stimulus.js
module FormField
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
  def form_field(type, **other_args)
    field_name = caller_locations.first.label

    view.capture do
      view.concat expense_entry_form.send(type, field_name, field_args(field_name, other_args))
      if expense_entry.errors[field_name].present?
        view.concat view.tag.small(expense_entry.errors[:date].join(', '), class: 'text-danger')
      end
    end
  end

  # @param [String] field_name
  def form_field_class(field_name = nil)
    field_name ||= caller_locations.first.label
    'form-control' + (expense_entry.errors[field_name].present? ? ' is-invalid' : '')
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
  # field_args('date', class: :date_field, placeholder: 'My special Date') =>
  # { class: :date, placeholder: 'Date',
  #   data: { action: 'focus->expense-claim#focusOnExpenseEntry change->expense-claim#changeToExpenseEntry' }
  # }
  #
  # @param [String] field_name
  # @param [Hash] other_args
  # @return [Hash]
  def field_args(field_name, other_args)
    default_hash(field_name).deep_merge!(other_args) do |key, this_val, other_val|
      case key
      when :class, :placeholder
        other_val
      else
        [this_val.to_s, other_val.to_s].join(' ')
      end
    end
  end

  # Generates, based on the field name, the default hash that the form field would use.
  #
  # @api private
  # @param [String] field_name
  # @return [Hash]
  def default_hash(field_name)
    { class: form_field_class(field_name.to_sym),
      placeholder: field_name.capitalize,
      data: { action: 'focus->expense-claim#focusOnExpenseEntry change->expense-claim#changeToExpenseEntry' }
    }
  end
end