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
require "database_cleaner"
require "logger"
require "tenancy"

# active_record
if Gem.loaded_specs["activerecord"]
  load File.dirname(__FILE__) + "/support/active_record/schema.rb"
  load File.dirname(__FILE__) + "/support/active_record/models.rb"
  require "shoulda-matchers"
end

# mongoid
if Gem.loaded_specs["mongoid"]
  load File.dirname(__FILE__) + "/support/mongoid/connection.rb"
  load File.dirname(__FILE__) + "/support/mongoid/models.rb"
  require "mongoid-rspec"
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end
  config.include Mongoid::Matchers, mongoid: true if defined?(Mongoid)

  config.around(:each) do |example|
    if example.metadata[:log]
      if defined?(ActiveRecord)
        ActiveRecord::Base.logger = Logger.new(STDOUT)
      end
      if defined?(Mongoid)
        Mongoid.logger.level = Logger::DEBUG
        Moped.logger.level = Logger::DEBUG
      end
    end
    DatabaseCleaner.start

    example.run

    if defined?(ActiveRecord)
      ActiveRecord::Base.logger = nil
    end
    if defined?(Mongoid)
      Mongoid.logger.level = Logger::INFO
      Moped.logger.level = Logger::INFO
    end
    DatabaseCleaner.clean
  end
end