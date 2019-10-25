# frozen_string_literal: true

# Used to generate key fields for a single row (an Expense Entry) in the Expense Claim HTML page.
class ExpenseEntryForPrintPresenter < BasePresenter
  # Initializer
  #
  # @api public
  # @param [ActiveView::Template] view
  def initialize(view, expense_entry)
    super(view, expense_entry)
  end

  alias expense_entry model

  delegate :sequence, :category, :description, :project, :qty, to: :model

  def date
    expense_entry.date.strftime("%d/%m/%Y")
  end

  def vat
    "#{expense_entry.vat}%"
  end

  def unit_cost
    expense_entry.unit_cost.format
  end

  def total_cost
    expense_entry.total_cost.format
  end

  def receipt_h2
    view.capture do
      view.tag.div(class: 'page-break') if expense_entry.email_receipt && expense_entry.sequence > 1
      view.tag.h3 "Receipt for #{expense_entry.sequence}: #{expense_entry.description}"
    end
  end

  def render_receipt
    if expense_entry.email_receipt
      view.capture do
        # view.tag.div expense_entry.email_receipt.body
        render_attachments
      end
    elsif expense_entry.receipt.attached?
      view.image_tag expense_entry.receipt, class: 'receipt-img'
    end
  end

  def render_attachments
    expense_entry.email_receipt.attachments.each do |attachment|
      if attachment.content_type == 'application/pdf'
        view.haml_tag :object, data: view.url_for(attachment), type: 'application/pdf' do
          view.haml_tag :iframe, src: "https://docs.google.com/viewer?url=#{view.url_for(attachment)}&embedded=true"
        end
      elsif attachment.image? && !expense_entry.email_receipt.embedded_images&.includes(attachment.id)
        view.image_tag attachment, class: 'receipt-img'
      end
    end
  end
end