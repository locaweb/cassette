# frozen_string_literal: true

describe Cassette::Client::Cache do
  it 'uses the cache store set in configuration' do
    # setup
    global_cache = double('cache_store')
    Cassette.cache_backend = global_cache

    logger = Logger.new('/dev/null')

    # exercise
    client_cache = described_class.new(logger)

    expect(client_cache.backend).to eq(global_cache)

    # tear down
    Cassette.cache_backend = nil
  end

  describe '.backend=' do
    it 'sets the cache' do
      # setup
      global_cache = double('cache_store')
      logger = Logger.new('/dev/null')

      # exercise
      Cassette::Client.cache.backend = global_cache

      # verify
      client_cache = described_class.new(logger)
      expect(client_cache.backend).to eql(global_cache)

      # tear down
      Cassette.cache_backend = nil
    end
  end
end
