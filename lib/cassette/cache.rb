# encoding: UTF-8

begin
  require 'active_support'
  require 'active_support/cache'
rescue LoadError
  require 'cassette/cache/null_store'
end

module Cassette
  module Cache
    def uses_key(key)
      "uses:#{key}"
    end

    def fetch(key, options = {}, &block)
      if options[:max_uses].to_i != 0
        uses_key = self.uses_key(key)
        uses = backend.read(uses_key, raw: true)
        backend.write(uses_key, 0, raw: true, expires_in: options[:expires_in]) if uses.nil?

        if uses.to_i >= options[:max_uses].to_i
          options[:force] = true
          backend.write(uses_key, 0, raw: true, expires_in: options[:expires_in])
        else
          backend.increment(uses_key)
        end
      end

      backend.fetch(key, options, &block)
    end

    def backend
      Cassette.cache_backend
    end

    def backend=(backend)
      Cassette.cache_backend = backend
    end

    def self.backend=(backend)
      ::Cassette.cache_backend = backend
    end
  end
end
