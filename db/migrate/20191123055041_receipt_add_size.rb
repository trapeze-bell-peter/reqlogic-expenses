class ReceiptAddSize < ActiveRecord::Migration[6.0]
  def change
    add_column :receipts, :receipt_size, :integer, default: 0, null: false

    Receipt.joins(:expense_entry).each do |receipt|
      receipt.attachments.each do |attachment|
        next unless attachment.image?

        if attachment.metadata['width'] == 2550
          receipt.update!(receipt_size: :a4)
        elsif receipt.expense_entry.description =~ /train|rail/i
          receipt.update!(receipt_size: :train_ticket)
        else
          receipt.update!(receipt_size: :till_receipt)
        end

        break
      end
    end
  end
end
