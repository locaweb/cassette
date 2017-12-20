# encoding: UTF-8

module Cassette
  class Authentication
    def self.method_missing(name, *args)
      @default_authentication ||= new
      @default_authentication.send(name, *args)
    end

    def initialize(opts = {})
      self.config = opts.fetch(:config, Cassette.config)
      self.logger = opts.fetch(:logger, Cassette.logger)
      self.http   = opts.fetch(:http_client, Cassette::Http::Request.new(config))
      self.cache  = opts.fetch(:cache, Cassette::Authentication::Cache.new(logger))
    end

    def validate_ticket(ticket, service = config.service)
      logger.debug "Cassette::Authentication validating ticket: #{ticket}, #{service}"
      fail Cassette::Errors::AuthorizationRequired if ticket.blank?

      user = ticket_user(ticket, service)
      logger.info "Cassette::Authentication user: #{user.inspect}"

      fail Cassette::Errors::Forbidden unless user

      user
    end

    def ticket_user(ticket, service = config.service)
      cache.fetch_authentication(ticket, service) do
        begin
          logger.info("Validating #{ticket} on #{validate_path}")

          response = http.get(validate_path, ticket: ticket, service: service).body
          ticket_response = Http::TicketResponse.new(response)

          logger.info("Validation resut: #{response.inspect}")

          Cassette::Authentication::User.new(
            login: ticket_response.login,
            name: ticket_response.name,
            authorities: ticket_response.authorities,
            ticket: ticket,
            config: config
          ) if ticket_response.login
        rescue => exception
          logger.error "Error while authenticating ticket #{ticket}: #{exception.message}"
          raise Cassette::Errors::Forbidden, exception.message
        end
      end
    end

    protected

    attr_accessor :cache, :logger, :http, :config

    def validate_path
      "/serviceValidate"
    end
  end
end
