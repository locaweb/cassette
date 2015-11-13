require 'delegate'
require 'active_support/xml_mini'

module Cassette
  module Http
    class ParsedResponse < SimpleDelegator
      def initialize(raw_content, parser = XMLParser)
        super(parser.call(raw_content))
      end

      XMLParser = lambda do |raw_content|
        ActiveSupport::XmlMini.with_backend('LibXML') do
          ActiveSupport::XmlMini.parse(raw_content)
        end
      end

      private_constant :XMLParser
    end
  end
end
