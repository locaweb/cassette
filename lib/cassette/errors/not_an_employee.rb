# encoding: utf-8

module Cassette
  module Errors
    class NotAnEmployee < Cassette::Errors::Base
      def code
        403
      end
    end
  end
end
