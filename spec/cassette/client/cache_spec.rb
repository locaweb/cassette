# encoding: utf-8



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
end
