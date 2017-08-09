require 'rexml/document'
require 'rexml/xpath'

module Cassette
  module Http
    class TicketResponse
      attr_reader :login, :name, :authorities

      def initialize(response)
        namespaces = { "cas" => "http://www.yale.edu/tp/cas" }
        query = "//cas:serviceResponse/cas:authenticationSuccess/cas:user"

        document = REXML::Document.new(response)
        element = REXML::XPath.first(document, query, namespaces)
        @login = element.try(:text)

        if @login
          attributes_query =
            "//cas:serviceResponse/cas:authenticationSuccess/cas:attributes"
          attributes = Hash[REXML::XPath.
            first(document, attributes_query, namespaces).
            elements.
            map { |e| [e.name, e.text] }]

          @name = attributes['cn']
          @authorities = attributes['authorities']
        end
      end
    end
  end
end
