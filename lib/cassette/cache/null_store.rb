# encoding: UTF-8

module Cassette
  module Cache
    # You cache nothing, null store
    #
    # This is a fallback class when Rails or ActiveSupport cache cannot
    # be loaded
    class NullStore
      def clear
      end

      def read(_key, _options)
        nil
      end

      def delete_matched(_key)
        true
      end

      def write(_key, _value, _options)
        true
      end

      def increment(_key)
        0
      end

      def fetch(_key, _options, &block)
        block.call
      end
    end
  end
end
