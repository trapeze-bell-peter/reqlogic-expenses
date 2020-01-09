# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0'

# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

# Use Puma as the app server
gem 'puma', '~> 3.12'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use HAML to represent the HTML
gem 'haml'

# Use Redis adapter to run Action Cable in production
gem 'redis'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Provide suitable authorisation checking for editing
gem 'cancancan'

# Gem to access convert_api for converting PDF to set of images
gem 'convert_api'

# Use Devise for security
gem 'devise'

# Give ability to view images.
gem 'image_processing', '~> 1.2'

# Gem to access Azure storage container
gem 'azure-storage'

# Support for money added
gem 'money-rails', '~>1.12'

# Support for reading and writing Excel files added
gem 'rubyXL'

# Barclay card generate xls files rather than xlsx.  So need this Gem to read the file :-(
gem 'spreadsheet'

# Background processing
gem 'sidekiq'

group :development, :test do
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 3.9'
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
