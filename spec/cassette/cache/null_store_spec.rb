# frozen_string_literal: true

require 'cassette/cache/null_store'

describe Cassette::Cache::NullStore do
  subject(:cache) { described_class.new }

  describe '#read' do
    it 'always return nils' do
      expect(cache.read('key')).to be_nil
    end

    it 'always return nils even when cache is written' do
      cache.write('key', 'value')

      expect(cache.read('key')).to be_nil
    end

    it 'accepts options' do
      expect(cache.read('key', raw: true)).to be_nil
    end
  end

  describe '#delete_matched' do
    it 'returns true' do
      expect(cache.delete_matched('key*')).to eq(true)
    end
  end

  describe '#write' do
    it 'returns true' do
      expect(cache.write('key', 'value')).to eq(true)
    end

    it 'accepts options' do
      expect(cache.write('key', 'value', expires_in: 3600)).to eq(true)
    end

    it 'does not actually write' do
      cache.write('key', 'value')

      expect(cache.read('key')).to be_nil
    end
  end

  describe '#increment' do
    it 'returns 0' do
      expect(cache.increment('key')).to be_zero
    end

    it '"accepts" a value to increment by' do
      expect(cache.increment('key', 2)).to be_zero
    end

    it '"accepts" options' do
      expect(cache.increment('key', 2, raw: true)).to be_zero
    end

    it 'does not really increment' do
      cache.increment('key')

      expect(cache.increment('key')).to be_zero
    end
  end

  describe '#fetch' do
    it 'always calls the block' do
      counter = 0

      cache.fetch('key') { counter += 1 }
      cache.fetch('key') { counter += 1 }

      expect(counter).to eq(2)
    end

    it 'accepts options' do
      expect(cache.fetch('key', expires_in: 3600) { 0 }).to eq(0)
    end
  end
end
