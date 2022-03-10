module Cassette
  module Rubycas
    module UserFactory
      def from_session(session)
        attributes = session[:cas_extra_attributes]
        attributes = attributes.with_indifferent_access if attributes.respond_to?(:with_indifferent_access)
        Cassette::Authentication::User.new(login: session[:cas_user],
                                           name: attributes.try(:delete, :cn),
                                           email: attributes.try(:delete, :email),
                                           authorities: attributes.try(:delete, :authorities),
                                           type: attributes.try(:delete, :type).try(:downcase),
                                           extra_attributes: attributes)
      end
    end
  end
end
