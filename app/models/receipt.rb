# frozen_string_literal: true

# Used to store details of a receipt associated with an expense_entry
class Receipt < ApplicationRecord
  belongs_to :expense_entry
  has_many_attached :attachments

  enum receipt_size: %i[till_receipt a4 train_ticket]

  # User is defined by who this expense claim belongs to
  delegate :user, :user_id, to: :expense_entry

  # evaluate whether the attachment is a PDF.
  def self.is_pdf?(attachment)
    attachment.content_type =~ /^application\/pdf/ || attachment.filename =~ /\.pdf$/i
  end

  # Goes through all the attachments in the incoming email.  If the attachment is a PDF use web service to get convert
  # it to JPG so we can print it out later.
  #
  # @param [ActiveStorage::Attachment] attachment - details of the attachment
  # @param [ActiveStorage::Blob] blob the associated blob for the attachment
  # @return [Array<ActiveStorage::Blob>] array of the JPG images converted from the PDF
  def convert_pdf_to_jpgs(attachment, blob)
    pdf_url = blob.service_url
    jpgs = ConvertApi.convert('jpg', { File: pdf_url }, from_format: 'pdf')
    jpgs.response['Files'].each_with_index do |jpg_file, page|
      self.attachments.attach io: URI.open(jpg_file['Url']),
                              filename: "#{attachment.filename} - Page #{page + 1}",
                              content_type: 'image/jpeg'

    end
  end
end
