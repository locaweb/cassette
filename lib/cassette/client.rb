# encoding: UTF-8

module Cassette
  class Client
    def self.method_missing(name, *args)
      @default_client ||= new
      @default_client.send(name, *args)
    end

    def initialize(opts = {})
      self.config = opts.fetch(:config, Cassette.config)
      self.logger = opts.fetch(:logger, Cassette.logger)
      self.http   = opts.fetch(:http_client, Cassette)
      self.cache  = opts.fetch(:cache, Cassette::Client::Cache.new(logger))
    end

    def health_check
      st_for('monitoring')
    end

    def tgt(usr, pwd, force = false)
      logger.info 'Requesting TGT'
      cache.fetch_tgt(force: force) do
        response = http.post(tickets_uri, username: usr, password: pwd)
        tgt = Regexp.last_match(1) if response.headers['Location'] =~ /tickets\/(.*)/
        logger.info "TGT is #{tgt}"
        tgt
      end
    end

    def st(tgt_param, service, force = false)
      logger.info "Requesting ST for #{service}"
      cache.fetch_st(service, force: force) do
        tgt = tgt_param.respond_to?(:call) ? tgt_param[] : tgt_param
        response = http.post("#{tickets_uri}/#{tgt}", service: service)
        response.body.tap do |st|
          logger.info "ST is #{st}"
        end
      end
    end

    def st_for(service_name)
      st_with_retry(config.username, config.password, service_name)
    end

    protected

    attr_accessor :cache, :logger, :http, :config

    def st_with_retry(user, pass, service, retrying = false)
      st(->{ tgt(user, pass, retrying) }, service)
    rescue Cassette::Errors::NotFound => e
      raise e if retrying

      logger.info 'Got 404 response, regenerating TGT'
      retrying = true
      retry
    end

    def tickets_uri
      "#{config.base.gsub(/\/?$/, '')}/v1/tickets"
    end
  end
end
