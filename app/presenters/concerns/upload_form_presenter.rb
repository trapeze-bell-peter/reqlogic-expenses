# frozen_string_literal: true

# Concern that provides the some common methods for the upload presenters.
module UploadFormPresenter
  extend ActiveSupport::Concern

  STIMULUS_ACTIONS_FOR_FORM = 'ajax:complete->expense-claim#ajaxComplete'

  attr_accessor :form
  delegate :text_field, :file_field, :hidden_field, :label, :submit, to: :form

  class_methods do
    # The form used for all three uploads is identical.  Its the fields that differ.  Therefore provide a standard
    # factory method to create it.
    def create_upload_form(view, form_id, scope)
      presenter = self.new(view, nil)

      view.form_with url: 'PLACEHOLDER-URL', scope: scope, id: form_id, class: 'form-horizontal', method: :patch,
                     data: { action: STIMULUS_ACTIONS_FOR_FORM } do |form|
        presenter.form = form
        yield(presenter)
      end
    end

    # This form is specifically for the current receipt.  It creates a radio button group allowing the user to change
    # the scale of the current receipt.
    def create_current_receipt_form(view)
      presenter = self.new(view, nil)

      view.form_with url: 'PLACEHOLDER-URL', scope: 'file_receipts', id: 'current-receipt-form',
                     class: 'form-horizontal', method: :patch,
                     data: { action: 'receipt#setReceiptSize ajax:complete->expense-claim#ajaxComplete' } do |form|
        presenter.form = form
        yield(presenter)
      end
    end
  end

  APPLY_BTN_CLASSES = 'button btn btn-primary mx-auto'
  def apply_btn
    self.form.submit 'Apply', class: APPLY_BTN_CLASSES
  end

  DELETE_BTN_CLASSES = 'delete-btn btn btn-primary mx-auto'
  def destroy_btn
    view.link_to 'Delete', 'PLACEHOLDER-URL', method: :delete, class: DELETE_BTN_CLASSES,
                                              remote: true,
                                              data: { action: 'ajax:complete->receipt#deleteReceiptComplete' }
  end

  def cancel_btn
    view.button_tag 'Cancel', type: 'button', class: 'button btn btn-secondary mx-auto',
                              data: { 'dismiss' => 'modal', type: 'button' }
  end

  def receipt_size_radio_group
    self.view.tag.div class: 'form-group btn-group btn-group-toggle', data: { toggle: 'buttons'} do
      Receipt.receipt_sizes.keys.each { |receipt_size| view.concat self.scale_btn(receipt_size) }
    end
  end

  def scale_btn(receipt_size)
    self.form.label :receipt_size, receipt_size,
                    class: 'receipt-size btn btn-secondary',
                    autocomplete: :off,
                    for: nil,
                    data: { target: 'receipt.receiptSizeLabel' } do
      view.concat(self.form.radio_button(:receipt_size, receipt_size, value: receipt_size))
      view.concat(receipt_size.to_s.humanize)
    end
  end
end
