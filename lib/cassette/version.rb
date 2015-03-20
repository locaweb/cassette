module Cassette
  class Version
      MAJOR = "1"
      MINOR = "0"

      def self.build_number
        ENV["BUILD_NUMBER"] || 2
      end

      def self.version
        [MAJOR, MINOR, build_number].join(".")
      end
  end
end

