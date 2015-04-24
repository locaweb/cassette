# encoding: UTF-8

require 'cassette/authentication'
require 'cassette/cache'

class Cassette::Authentication::Cache
  include Cassette::Cache

  def initialize(logger)
    self.logger = logger
  end

  def fetch_authentication(ticket, service, options = {}, &block)
    options = { expires_in: 5 * 60, max_uses: 5000, force: false }.merge(options)
    fetch("Cassette::Authentication.validate_ticket(#{ticket}, #{service})", options) do
      logger.info("Authentication for #{ticket}, #{service} is not cached")
      block.call
    end
  end

  def clear_authentication_cache!
    backend.delete_matched('Cassette::Authentication.validate_ticket*')
    backend.delete_matched("#{uses_key('Cassette::Authentication.validate_ticket')}*")
  end

  protected

  attr_accessor :logger
end
