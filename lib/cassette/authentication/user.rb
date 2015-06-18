# encoding: UTF-8

require 'cassette/authentication'
require 'cassette/authentication/authorities'
require 'delegate'

module Cassette
  class Authentication
    class User
      attr_accessor :login, :name, :authorities, :email, :ticket, :type
      delegate :has_role?, :has_raw_role?, to: :@authorities

      def initialize(attrs = {})
        config       = attrs[:config]
        @login       = attrs[:login]
        @name        = attrs[:name]
        @type        = attrs[:type]
        @email       = attrs[:email]
        @ticket      = attrs[:ticket]
        @authorities = Cassette::Authentication::Authorities
                       .parse(attrs.fetch(:authorities, '[]'), config && config.base_authority)
      end

      %w(customer employee).each do |type|
        define_method :"#{type}?" do
          !@type.nil? && @type.to_s.downcase == type.to_s
        end
      end
    end
  end
end
