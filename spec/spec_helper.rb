require "simplecov"
require "coveralls"
require "codeclimate-test-reporter"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter,
  CodeClimate::TestReporter::Formatter
]

SimpleCov.start do
  add_filter "/spec/"
end

require "pry"
require "tenancy"

# active_record
load File.dirname(__FILE__) + "/support/active_record/schema.rb"
load File.dirname(__FILE__) + "/support/active_record/models.rb"

# mongoid
load File.dirname(__FILE__) + "/support/mongoid/connection.rb"
load File.dirname(__FILE__) + "/support/mongoid/models.rb"

require "mongoid-rspec"
require "shoulda-matchers"
RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.include Mongoid::Matchers, mongoid: true

  # Clean/Reset Mongoid DB prior to running the tests
  config.before :each do
    Mongoid.default_session.drop
  end
end