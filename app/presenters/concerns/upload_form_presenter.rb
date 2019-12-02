# frozen_string_literal: true

# Concern that provides the some common methods for the upload presenters.
module UploadFormPresenter
  extend ActiveSupport::Concern

  STIMULUS_ACTIONS_FOR_FORM =
    'direct-uploads:end->receipt#dismissReceiptModal ajax:complete->expense-claim#ajaxComplete'

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
  end

  DELETE_BTN_CLASSES = 'delete-btn btn btn-primary mx-auto'
  def destroy_btn
    view.link_to 'Delete', 'PLACEHOLDER-URL', method: :delete, class: DELETE_BTN_CLASSES, remote: true,
                                              data: { action: STIMULUS_ACTIONS_FOR_FORM }
  end

  def cancel_btn
    view.button_tag 'Cancel', type: 'button', class: 'button btn btn-secondary mx-auto',
                              data: { 'dismiss' => 'modal', :type => 'button' }
  end
end
