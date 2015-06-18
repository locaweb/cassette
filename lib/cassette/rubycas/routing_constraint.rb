module Cassette
  module Rubycas
    class RoutingConstraint
      include UserFactory

      attr_reader :role, :options

      def initialize(role, opts = {})
        defaults = { raw: false }
        @role = role
        @options = defaults.merge(opts)
      end

      def matches?(request)
        user = from_session(request.session)

        meth = options[:raw] ? :has_raw_role? : :has_role?

        user.send(meth, role)
      end
    end
  end
end
