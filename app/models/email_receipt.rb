# frozen_string_literal: true

# Used to store details of a receipt sent as an email.
class EmailReceipt < Receipt
  attr_reader :mail, :embedded_images, :document

  # Virtual setter that will extract all the key info from the incoming email receipt and update this object
  # accordingly.
  def mail=(incoming_mail)
    @mail = incoming_mail
    @embedded_images = []
    @document = Nokogiri::HTML(incoming_mail.html_part.body.decoded) if incoming_mail.multipart? && incoming_mail.html_part

    self.expense_entry.receipt.purge
    self.title = mail.subject
    attachments_in_email_receipt
    extract_body
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

      if attachment.content_type =~ /^application\/pdf/ || attachment.filename =~ /\.pdf$/i
        convert_pdf_to_jpgs(attachment, blob)
      elsif mail.multipart? && mail.html_part
        replace_embedded_image_in_html(attachment, blob)
      end
    end
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

  # Replace the HTML for embedded images associated with the specific attachment with a reference to the Blob in
  # in active storage.
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

    self.document.at_css("img[src='cid:#{content_id}']")&.attributes['src'] = url_for(attachment)
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