module Cassette
  module Http
    module Request
      extend self

      def post(uri, payload, timeout = DEFAULT_TIMEOUT)
        perform(:post, uri, timeout) do |request|
          request.body = URI.encode_www_form(payload)
        end
      end

      private

      def perform(http_verb, uri, timeout, &block)
        request(uri, timeout)
          .tap(&log_request)
          .public_send(http_verb, &block)
          .tap(&check_response)
      end

      def request(uri, timeout)
        Faraday.new(url: uri, ssl: { verify: false, version: 'TLSv1' }) do |con|
          con.adapter Faraday.default_adapter
          con.options.timeout = timeout
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
