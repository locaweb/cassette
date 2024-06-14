#!/usr/bin/env rake

require 'bundler/gem_tasks'

if defined?(RSpec)
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |task|
    task.rspec_opts = '--format RspecJunitFormatter  --out spec/reports/rspec.xml --format documentation --color'
  end
end
