# encoding: UTF-8

require 'cassette/authentication'
require 'cassette/authentication/authorities'
require 'forwardable'

module Cassette
  class Authentication
    class User
      extend Forwardable

      attr_accessor :login, :name, :authorities, :email, :ticket, :type
      def_delegators :@authorities, :has_role?, :has_raw_role?

      def initialize(attrs = {})
        config       = attrs[:config]
        @login       = attrs[:login]
        @name        = attrs[:name]
        @type        = attrs[:type]
        @email       = attrs[:email]
        @ticket      = attrs[:ticket]
        @attributes  = attrs
        @authorities = Cassette::Authentication::Authorities
                       .parse(attrs.fetch(:authorities, '[]'), config && config.base_authority)
      end

      def attribute(key)
        @attributes[key]
      end

      %w(customer employee).each do |type|
        define_method :"#{type}?" do
          !@type.nil? && @type.to_s.downcase == type.to_s
        end
      end
    end
  end
end
