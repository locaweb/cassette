# encoding: UTF-8

require 'cassette/client'
require 'cassette/cache'

module Cassette
  class Client
    class Cache
      include Cassette::Cache

      def initialize(logger)
        self.logger = logger
      end

      def fetch_tgt(options = {}, &_block)
        options = { expires_in: 4 * 3600, max_uses: 5000, force: false }.merge(options)
        fetch('Cassette::Client.tgt', options) do
          self.clear_st_cache!
          logger.info 'TGT is not cached'
          yield
        end
      end

      def fetch_st(service, options = {}, &_block)
        options = { max_uses: 2000, expires_in: 252, force: false }.merge(options)
        fetch("Cassette::Client.st(#{service})", options) do
          logger.info "ST for #{service} is not cached"
          yield
        end
      end

      def clear_tgt_cache!
        backend.delete('Cassette::Client.tgt')
        backend.delete("#{uses_key('Cassette::Client.tgt')}")
      end

      def clear_st_cache!
        backend.delete_matched('Cassette::Client.st*')
        backend.delete_matched("#{uses_key('Cassette::Client.st')}*")
      end

      protected

      attr_accessor :logger
    end
  end
end
