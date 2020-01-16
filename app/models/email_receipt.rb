# frozen_string_literal: true

# Used to store details of a receipt sent as an email.
class EmailReceipt < Receipt
  include Rails.application.routes.url_helpers

  attr_reader :mail, :embedded_images, :document

  # Because of the way that the upload mechanisms work, things are async, so we check wether we have an upload
  def arrived?
    self.email_body
  end

  # Virtual setter that will extract all the key info from the incoming email receipt and update this object
  # accordingly.
  def mail=(incoming_mail)
    @mail = incoming_mail
    @embedded_images = []
    @document = Nokogiri::HTML(incoming_mail.html_part.body.decoded) if incoming_mail.multipart? && incoming_mail.html_part

    extract_body
    self.attachments.purge
    self.title = mail.subject
    attachments_in_email_receipt
  end

  private

  # Extracts the attachments, saves them to ActiveStorage and returns an array of the Blobs holding the extracted
  # images
  #
  # @api private
  # @return [Array<ActiveStorage::Blob>]
  def attachments_in_email_receipt
    mail.attachments.each do |attachment|
      blob = ActiveStorage::Blob.create_after_upload!(io: StringIO.new(attachment.body.to_s),
                                                      filename: attachment.filename,
                                                      content_type: attachment.content_type)

      if Receipt.is_pdf?(attachment)
        convert_pdf_to_jpgs(attachment, blob)
      elsif mail.multipart? && mail.html_part
        replace_embedded_image_in_html(attachment, blob)
      end
    end
  end

  # Replace the HTML for embedded images associated with the specific attachment with a reference to the Blob in
  # active storage.
  #
  # @api private
  #
  # @param [ActiveStorage::Attachment] attachment - details of the PDF attachment
  # @param [ActiveStorage::Blob] blob the associated blob for the PDF attachment
  # @return [Void]
  def replace_embedded_image_in_html(attachment, blob)
    # Remove the beginning and end < >
    content_id = attachment.content_id[1...-1]

    element = self.document.at_css("img[src='cid:#{content_id}']")

    return unless element

    self.document.at_css("img[src='cid:#{content_id}']")&.attributes['src'] =
        Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)

    self.embedded_images << blob.id
  end

  # Extracts the body of the email text.  If HTML ensures it is encoded in UTF-8.
  def extract_body
    self.email_body =
      if self.mail.multipart? && self.mail.html_part
        self.document.at_css('body').inner_html.encode('utf-8')
      elsif self.mail.multipart? && self.mail.text_part
        self.mail.text_part.body.decoded
      else
        self.mail.decoded
      end
  end
end