FactoryBot.define do
  factory :email_receipt do
    # Create an empty email receipt with appropriate token.
    factory :expected_email_receipt do
      email_receipt_token { 'u2iclhr1' }
    end
  end
end
