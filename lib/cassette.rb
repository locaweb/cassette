# encoding: UTF-8

require 'cassette/errors'
require 'cassette/cache'
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

  def new_request(uri, timeout)
    Faraday.new(url: uri, ssl: { verify: false, version: 'TLSv1' }) do |builder|
      builder.adapter :httpclient
      builder.options.timeout = timeout
    end
  end

  def get(uri, payload, timeout = DEFAULT_TIMEOUT)
    perform(:get, uri, payload, timeout) do |req|
      req.params = payload
      logger.debug "Request: #{req.inspect}"
    end
  end

  def post(uri, payload, timeout = DEFAULT_TIMEOUT)
    perform(:post, uri, payload, timeout) do |req|
      req.body = payload
      logger.debug "Request: #{req.inspect}"
    end
  end

  protected

  def perform(op, uri, _payload, timeout = DEFAULT_TIMEOUT, &block)
    request = new_request(uri, timeout)
    res = request.send(op, &block)

    res.tap do |response|
      logger.debug "Got response: #{response.body.inspect} (#{response.status}), #{response.headers.inspect}"
      Cassette::Errors.raise_by_code(response.status) unless response.success?
    end
  end
end
