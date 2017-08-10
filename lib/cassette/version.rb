module Cassette
  class Version
    MAJOR = '1'
    MINOR = '2'
    PATCH = '0.pre'

    def self.version
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
