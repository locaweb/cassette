# encoding: UTF-8

module Cassette
  module Rubycas
    class SingleSignOutConstraint
      LOGOUT_PAYLOAD_EXPR = %r{<samlp:LogoutRequest.*?<samlp:SessionIndex>(.*)<\/samlp:SessionIndex}m

      def logout_request?(params)
        [params['logoutRequest'], URI.unescape(params['logoutRequest'])].find { |xml| xml =~ LOGOUT_PAYLOAD_EXPR }
      end

      def matches?(request)
        if (content_type = request.headers['CONTENT_TYPE']) && content_type =~ %r{^multipart/}
          return false
        end

        if request.post? && request.request_parameters['logoutRequest'] && logout_request?(request.request_parameters)
          Cassette.logger.debug "Intercepted a single sign out request on #{request}"
          return true
        end

        false
      end
    end
  end
end
