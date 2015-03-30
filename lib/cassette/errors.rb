# encoding: UTF-8

require 'active_support/inflector'

module Cassette
  module Errors
    TYPES = {
      401 => :authorization_required,
      400 => :bad_request,
      403 => :forbidden,
      500 => :internal_server_error,
      404 => :not_found,
      412 => :precondition_failed
    }

    def self.raise_by_code(code)
      name = TYPES[code.to_i]

      if name
        fail error_class(name)
      else
        fail error_class(:internal_server_error)
      end
    end

    def self.error_class(name)
      "Cassette::Errors::#{name.to_s.camelize}".constantize
    end

    class Base < StandardError
      def code
        self.class.const_get('CODE')
      end
    end

    TYPES.each do |status, name|
      const_set(name.to_s.camelize, Class.new(Errors::Base))
      error_class(name).const_set('CODE', status)
    end
  end
end

require 'cassette/errors/not_an_employee'
require 'cassette/errors/not_a_customer'
