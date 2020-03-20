module Cassette
  class Version
    MAJOR = '1'.freeze
    MINOR = '4'.freeze
    PATCH = '0'.freeze

    def self.version
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
