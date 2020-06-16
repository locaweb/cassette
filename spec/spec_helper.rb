require 'simplecov'
require 'simplecov-rcov'
require 'simplecov-gem-adapter'
require 'yaml'
require 'webmock/rspec'
require 'rspec/its'
require 'faker'
if RUBY_VERSION >= '2.3.0'
  # require 'pry-byebug'
end

Dir['spec/support/**/*.rb'].each { |f| load f }

module Fixtures
  def fixture(name)
    File.read("spec/fixtures/#{name}")
  end
end

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.include Fixtures
  last_execution_result_file = 'spec/support/last_execution_examples_result.txt'
  config.example_status_persistence_file_path = last_execution_result_file
  config.order = 'random'
end

SimpleCov.start 'gem' do
  formatter SimpleCov::Formatter::RcovFormatter
  add_filter 'spec/'
  add_filter 'vendor/'
end

require 'cassette'
require 'cassette/rubycas'
require 'ostruct'

Cassette.config = OpenStruct.new(YAML.load_file('spec/config.yml'))
