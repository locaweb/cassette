# encoding: UTF-8

require 'active_support/xml_mini'
ActiveSupport::XmlMini.backend = 'LibXML'

module Cassette
  class Authentication
    def self.method_missing(name, *args)
      @@default_authentication ||= new
      @@default_authentication.send(name, *args)
    end

    def initialize(opts = {})
      self.config = opts.fetch(:config, Cassette.config)
      self.logger = opts.fetch(:logger, Cassette.logger)
      self.http   = opts.fetch(:http_client, Cassette)
      self.cache  = opts.fetch(:cache, Cassette::Authentication::Cache.new(logger))
    end

    def validate_ticket(ticket, service = config.service)
      logger.debug "Cassette::Authentication validating ticket: #{ticket}, #{service}"
      fail Cassette::Errors::AuthorizationRequired if ticket.nil? || ticket.blank?

      user = ticket_user(ticket, service)
      logger.info "Cassette::Authentication user: #{user.inspect}"

      fail Cassette::Errors::Forbidden unless user

      user
    end

    def ticket_user(ticket, service = config.service)
      cache.fetch_authentication(ticket, service) do
        begin
          logger.info("Validating #{ticket} on #{validate_uri}")
          response = http.post(validate_uri, ticket: ticket, service: service).body

          logger.info("Validation resut: #{response.inspect}")

          user = nil

          ActiveSupport::XmlMini.with_backend('LibXML') do
            result = ActiveSupport::XmlMini.parse(response)

            login = result.try(:[], 'serviceResponse').try(:[], 'authenticationSuccess').try(:[], 'user').try(:[], '__content__')

            if login
              attributes = result['serviceResponse']['authenticationSuccess']['attributes']
              name = attributes.try(:[], 'cn').try(:[], '__content__')
              authorities = attributes.try(:[], 'authorities').try(:[], '__content__')

              user = Cassette::Authentication::User.new(login: login, name: name, authorities: authorities, ticket: ticket, config: config)
            end
          end

          user
        rescue => exception
          logger.error "Error while authenticating ticket #{ticket}: #{exception.message}"
          raise Cassette::Errors::Forbidden.new(exception.message)
        end
      end
    end

    protected

    attr_accessor :cache, :logger, :http, :config

    def validate_uri
      "#{config.base.gsub(/\/?$/, '')}/serviceValidate"
    end
  end
end
