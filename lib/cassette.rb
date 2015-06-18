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

  attr_writer :config, :logger

  DEFAULT_TIMEOUT = 10

  def logger
    @logger ||= begin
                  if defined?(::Rails) && ::Rails.logger
                    ::Rails.logger
                  else
                    Logger.new('/dev/null')
                  end
                end
  end

  def config
    @config if defined?(@config)
  end

  delegate :post, to: :'Http::Request'
end
