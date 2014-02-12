require 'spec_helper'
require 'capybara/rspec'
require 'capybara/rails'
require 'rack_session_access/capybara'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

Capybara.default_wait_time = 3

def login_with(id=nil)
  page.set_rack_session(user_id: id)
end

def create_auction(seller_id, title, description, end_time)
  login_with(seller_id)
  visit new_auction_path

  fill_in 'Title', with: title
  fill_in 'Description', with: description
  fill_in 'End Date', with: end_time

  attach_file('Image', File.expand_path('public/test.png'))

  find('input[type="submit"]').click
end