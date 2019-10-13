class ApplicationMailbox < ActionMailbox::Base
  routing /receipts\.([[:alnum:]]{8})@tguk-expenses\.com/ => :receipts
end
