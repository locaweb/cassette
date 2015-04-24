# encoding: UTF-8

require 'active_support/concern'
require 'cassette/authentication/user'

module Cassette::Authentication::Filter
  extend ActiveSupport::Concern

  included do |controller|
    controller.before_filter(:validate_authentication_ticket)
    controller.send(:attr_accessor, :current_user)
  end

  module ClassMethods
    def skip_authentication(*options)
      skip_before_filter :validate_authentication_ticket, *options
    end
  end

  def accepts_authentication_service?(service)
    config = Cassette.config

    if config.respond_to?(:services)
      config.services.member?(service) || config.service == service
    else
      config.service == service
    end
  end

  def validate_authentication_ticket(service = authentication_service)
    ticket = request.headers['Service-Ticket'] || params[:ticket]

    if ENV['NOAUTH']
      Cassette.logger.debug 'NOAUTH set and no Service Ticket, skipping authentication'
      self.current_user = Cassette::Authentication::User.new
      return
    end

    fail Cassette::Errors::Forbidden unless accepts_authentication_service?(authentication_service)
    self.current_user = Cassette::Authentication.validate_ticket(ticket, service)
  end

  def authentication_service
    Cassette.config.service
  end

  def validate_role!(role)
    return if ENV['NOAUTH']
    fail Cassette::Errors::Forbidden unless current_user.has_role?(role)
  end

  def validate_raw_role!(role)
    return if ENV['NOAUTH']
    fail Cassette::Errors::Forbidden unless current_user.has_raw_role?(role)
  end
end
