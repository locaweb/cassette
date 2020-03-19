module Cassette
  class Version
    MAJOR = '1'
    MINOR = '3'
    PATCH = '0'

    def self.version
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
