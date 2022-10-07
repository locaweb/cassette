# frozen_string_literal: true

describe Cassette::Cache do
  subject(:cached) do
    cached
  end

  describe '#backend' do
    it 'returns the global cache' do
      # setup
      global_cache = instance_double(described_class, 'cache_store')
      Cassette.cache_backend = global_cache

      # exercise and verify
      expect(cached.backend).to eql(global_cache)

      # tear down
      Cassette.cache_backend = nil
    end
  end

  describe '.backend=' do
    it 'sets the cache' do
      # setup
      global_cache = instance_double(described_class, 'cache_store')
      described_class.backend = global_cache

      # exercise and verify
      expect(cached.backend).to eql(global_cache)

      # tear down
      Cassette.cache_backend = nil
    end
  end

  it 'invalidates the cache after the configured number of uses' do
    generator = double('Generator')
    allow(generator).to receive(:generate).twice

    6.times do
      cached.fetch('Generator', max_uses: 5) { generator.generate }
    end
  end

  def cached
    c = Class.new
    c.send(:include, Cassette::Cache)
    c.new
  end
end
