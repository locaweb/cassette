# frozen_string_literal: true

describe Cassette::Cache do
  subject do
    cached
  end

  describe '#backend' do
    it 'returns the global cache' do
      # setup
      global_cache = double('cache_store')
      Cassette.cache_backend = global_cache

      # exercise and verify
      expect(subject.backend).to eql(global_cache)

      # tear down
      Cassette.cache_backend = nil
    end
  end

  describe '.backend=' do
    it 'sets the cache' do
      # setup
      global_cache = double('cache_store')
      described_class.backend = global_cache

      # exercise and verify
      expect(subject.backend).to eql(global_cache)

      # tear down
      Cassette.cache_backend = nil
    end
  end

  it 'invalidates the cache after the configured number of uses' do
    generator = double('Generator')
    expect(generator).to receive(:generate).twice

    6.times do
      subject.fetch('Generator', max_uses: 5) { generator.generate }
    end
  end

  def cached
    c = Class.new
    c.send(:include, Cassette::Cache)
    c.new
  end
end
