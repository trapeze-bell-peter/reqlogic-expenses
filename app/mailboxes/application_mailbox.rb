class ApplicationMailbox < ActionMailbox::Base
  routing :all => :receipt
end
