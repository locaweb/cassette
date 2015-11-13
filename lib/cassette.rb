# encoding: UTF-8

require 'cassette/errors'
require 'cassette/cache'
require 'cassette/http'
require 'cassette/client/cache'
require 'cassette/client'
require 'cassette/authentication'
require 'cassette/authentication/authorities'
require 'cassette/authentication/user'
require 'cassette/authentication/cache'
require 'cassette/authentication/filter'

require 'faraday'
require 'logger'

module Cassette
  extend self

  DEFAULT_TIMEOUT = 10

  def logger
    @@logger ||= begin
                   if defined?(Rails) && Rails.logger
                     Rails.logger
                   else
                     Logger.new('/dev/null')
                   end
                 end
  end

  def logger=(logger)
    @@logger = logger
  end

  def config
    if defined?(@@config)
      @@config
    end
  end

  def config=(config)
    @@config = config
  end

  delegate :post, to: :'Http::Request'
end
