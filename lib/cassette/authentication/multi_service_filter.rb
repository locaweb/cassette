# encoding: UTF-8

require 'active_support/concern'
require 'cassette/authentication/filter'

module Cassette::Authentication::MultiServiceFilter
  extend ActiveSupport::Concern
  include Cassette::Authentication::Filter

  def validate_authentication_ticket
    config = Cassette.config
    if config.respond_to?(:services)
      services = Cassette.config.services
      service  = authentication_service

      if config.service == service || services.member?(service)
        super(service)
      else
        fail Cassette::Errors::Forbidden
      end
    else
      super(authentication_service)
    end
  end
end
