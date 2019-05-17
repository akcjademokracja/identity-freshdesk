require File.expand_path("../../../../config/environment.rb", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'faker'

require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

# Load support files
Dir["#{File.dirname(__FILE__)}/support/*.rb"].each { |f| require f }

require 'sidekiq'
require 'sidekiq/testing'
require 'factory_bot_rails'

Sidekiq::Testing.fake!

Rails.backtrace_cleaner.remove_silencers!

RSpec.configure do |config|
  config.include ApiHelper
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end
  config.filter_run_when_matching :focus
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.infer_spec_type_from_file_location!
  config.example_status_persistence_file_path = "spec/examples.txt"

  config.before(:each) do
    # Clear all (fake) Sidekiq jobs between tests
    Sidekiq::Worker.clear_all
  end
end

def admin_required!
  true
end

def has_permission?(_)
  true
end

def api_authentication_required!
  true
end

def current_account
  OpenStruct.new(name: 'RSpec Example')
end
