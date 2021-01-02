# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    factory :test_user do
      email { 'test.user@trapezegroup.com' }
      password { 'testpassword' }
    end
  end
end
