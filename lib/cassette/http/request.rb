module Cassette
  module Http
    class Request
      def self.method_missing(name, *args)
        @default_http ||= new
        @default_http.send(name, *args)
      end

      def initialize(config = Cassette.config)
        self.config = config
      end

      def post(path, payload, timeout = DEFAULT_TIMEOUT)
        perform(:post, path) do |req|
          req.body = URI.encode_www_form(payload)
          req.options.timeout = timeout
        end
      end

      def get(path, payload, timeout = DEFAULT_TIMEOUT)
        perform(:get, path) do |req|
          req.params = payload
          req.options.timeout = timeout
        end
      end

      private

      attr_accessor :config

      def perform(http_verb, path, &block)
        request
          .tap(&log_request)
          .public_send(http_verb, path, &block)
          .tap(&check_response)
      end

      def request
        @request ||= Faraday.new(url: config.base, ssl:
          { verify: config.verify_ssl, version: config.tls_version }) do |conn|
          conn.adapter Faraday.default_adapter
        end
      end

      def log_request
        lambda { |request| Cassette.logger.debug "Request: #{request.inspect}" }
      end

      def check_response
        lambda do |resp|
          Cassette.logger.debug(
            "Got response: #{resp.body.inspect} (#{resp.status}), " \
            "#{resp.headers.inspect}"
          )

          Cassette::Errors.raise_by_code(resp.status) unless resp.success?
        end
      end
    end
  end
end
