# encoding: UTF-8

module Cassette
  module Rubycas
    class SingleSignOutConstraint
      def matches?(request)
        if (content_type = request.headers['CONTENT_TYPE']) &&
           content_type =~ /^multipart\//
          return false
        end

        if request.post? &&
           request.request_parameters['logoutRequest'] &&
           [request.request_parameters['logoutRequest'],
            URI.unescape(request.request_parameters['logoutRequest'])]
           .find { |xml| xml =~ /^<samlp:LogoutRequest.*?<samlp:SessionIndex>(.*)<\/samlp:SessionIndex>/m }

          Cassette.logger.debug "Intercepted a single sign out request on #{request}"
          return true
        end

        false
      end
    end
  end
end
