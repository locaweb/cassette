module Cassette
  module Http
    class TicketResponse
      def initialize(response)
        @content = ParsedResponse.new(response)
      end

      def login
        fetch_val(
          content,
          'serviceResponse',
          'authenticationSuccess',
          'user',
          '__content__'
        )
      end

      def name
        fetch_val(attributes, 'cn', '__content__')
      end

      def authorities
        fetch_val(attributes, 'authorities', '__content__')
      end

      private

      attr_reader :content

      def fetch_val(hash, *keys)
        keys.reduce(hash, &access_key)
      end

      def access_key
        lambda { |hash, key| hash.try(:[], key) }
      end

      def attributes
        fetch_val(
          content,
          'serviceResponse',
          'authenticationSuccess',
          'attributes'
        )
      end
    end
  end
end
