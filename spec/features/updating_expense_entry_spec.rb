# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'updating an expense entry', type: :feature do
  before do
    allow_any_instance_of(User).to receive(:valid_password?) do |user, password|
      user.email == 'test.user@trapezegroup.com' && password == 'correct_password'
    end
  end

  context 'with a correct change' do
    specify do
      pending

      # when I load the claim form
      # and click into an existing row
      # and make a change
      # the form is not submitted yet
      # i then choose a new row
      # the original row is submitted
      # and an OK is returned
    end
  end

  describe 'that has not yet been added to the database' do
    pending
  end
end