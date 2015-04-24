require 'simplecov'
require 'simplecov-rcov'
require 'simplecov-gem-adapter'
require 'yaml'

Dir['spec/support/**/*.rb'].each { |f| load f }

module Fixtures
  def fixture(name)
    File.read("spec/fixtures/#{name}")
  end
end

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.include Fixtures
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
