module Cassette
  class Version
    MAJOR = '1'
    MINOR = '2'
    PATCH = '2'

    def self.version
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
