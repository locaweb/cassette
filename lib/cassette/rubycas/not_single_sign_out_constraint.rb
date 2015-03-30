# encoding: UTF-8

require 'cassette/rubycas/single_sign_out_constraint'

module Cassette
  module Rubycas
    class NotSingleSignOutConstraint < SingleSignOutConstraint
      def matches?(request)
        !super(request)
      end
    end
  end
end
