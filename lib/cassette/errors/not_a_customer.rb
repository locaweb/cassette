# encoding: utf-8

require 'cassette/errors'

module Cassette
  module Errors
    class NotACustomer < Cassette::Errors::Base
      def code
        403
      end
    end
  end
end
