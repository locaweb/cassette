# encoding: UTF-8

require 'cassette/authentication'

module Cassette
  class Authentication
    class Authorities
      def self.parse(authorities, base_authority = nil)
        new(authorities, base_authority)
      end

      def base
        @base_authority.to_s.upcase
      end

      def has_raw_role?(role)
        return true if ENV['NOAUTH']
        @authorities.include?(role)
      end

      def has_role?(role)
        return true if ENV['NOAUTH']
        has_raw_role?("#{base}_#{role.to_s.upcase.gsub('_', '-')}")
      end

      def initialize(authorities, base_authority = nil)
        @base_authority = base_authority || Cassette.config.base_authority

        if authorities.is_a?(String)
          @authorities = authorities.gsub(/^\[(.*)\]$/, '\\1').split(',').map(&:strip)
        else
          @authorities = Array(authorities).map(&:strip)
        end
      end

      def authorities
        @authorities.dup
      end
    end
  end
end
