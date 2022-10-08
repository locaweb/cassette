# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cassette/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Ricardo Hermida Ruiz']
  gem.email         = ['ricardo.ruiz@locaweb.com.br']
  gem.description   = 'Client for generating and validating CAS TGT/STs'
  gem.summary       = 'Generates, validates and caches TGTs and STs'
  gem.homepage      = 'http://github.com/locaweb/cassette'

  gem.add_runtime_dependency 'faraday', '> 0.9'

  gem.add_development_dependency 'activesupport', '> 3.1.0'
  gem.add_development_dependency 'json', '> 1.8.5'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rspec-its'
  gem.add_development_dependency 'rake'
  if RUBY_VERSION >= '2.3.0'
    gem.add_development_dependency 'pry-byebug'
  else
    gem.add_development_dependency 'pry'
  end
  gem.add_development_dependency 'rubycas-client'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'rubocop-rspec'
  gem.add_development_dependency 'simplecov-rcov'
  gem.add_development_dependency 'simplecov-gem-adapter'
  gem.add_development_dependency 'codeclimate-test-reporter', '~> 1.0.0'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'faker'

  gem.files         = %w(README.md) + Dir['lib/**/*'] + Dir['spec/**/*']
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'cassette'
  gem.require_paths = ['lib']
  gem.version       = Cassette::Version.version
end
