#!/usr/bin/env rake
# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'rspec/core/rake_task'

require 'cassette/version'

RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = '--format RspecJunitFormatter  --out spec/reports/rspec.xml --format documentation --color'
end
