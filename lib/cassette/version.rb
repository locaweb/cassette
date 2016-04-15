module Cassette
  class Version
    MAJOR = '1'
    MINOR = '1'
    PATCH = '1'

    def self.version
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
