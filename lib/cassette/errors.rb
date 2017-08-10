# encoding: UTF-8

module Cassette
  module Errors
    TYPES = {
      401 => :AuthorizationRequired,
      400 => :BadRequest,
      403 => :Forbidden,
      500 => :InternalServerError,
      404 => :NotFound,
      412 => :PreconditionFailed
    }

    def self.raise_by_code(code)
      name = TYPES[code.to_i]

      if name
        fail error_class(name)
      else
        fail error_class(:InternalServerError)
      end
    end

    def self.error_class(name)
      Cassette::Errors.const_get(name)
    end

    class Base < StandardError
      def code
        self.class.const_get('CODE')
      end
    end

    TYPES.each do |status, name|
      const_set(name, Class.new(Errors::Base))
      error_class(name).const_set('CODE', status)
    end
  end
end

require 'cassette/errors/not_an_employee'
require 'cassette/errors/not_a_customer'
