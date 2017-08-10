module Cassette
  module Rubycas
    module UserFactory
      def from_session(session)
        attributes = session[:cas_extra_attributes]
        Cassette::Authentication::User.new(login: session[:cas_user],
                                           name: attributes.try(:[], :cn),
                                           email: attributes.try(:[], :email),
                                           authorities: attributes.try(:[], :authorities),
                                           type: attributes.try(:[], :type).try(:downcase))
      end
    end
  end
end
