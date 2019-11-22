
class ReceiptPresenter
  # Create a corresponding receipt
  def self.create_receipt_presenter(view, receipt)
    "#{receipt.class.to_s}Presenter".safe_constantize.new(view, receipt)
  end
end