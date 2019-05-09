# encoding: utf-8

describe Cassette::Cache do
  subject do
    cached()
  end

  after do
    described_class.instance_variable_set(:@backend, nil)
  end

  describe '.backend' do
    it 'defaults to rails backend' do
      rails = double('Rails')
      cache = double('cache_backend')
      allow(rails).to receive(:cache).and_return(cache)
      stub_const('Rails', rails)

      expect(described_class.backend).to eql(cache)
    end
  end

  describe '.backend=' do
    it 'provides a default backend for new instances' do
      backend = double('backend')
      expect(subject.backend).not_to eq(backend)

      described_class.backend = backend

      new_instance = cached()
      expect(new_instance.backend).to eq(backend)
      expect(new_instance.backend).not_to eq(subject.backend)
    end

    it 'sets the default backend' do
      backend = double('backend')
      expect(described_class.backend).not_to eq(backend)

      described_class.backend = backend

      expect(described_class.backend).to eq(backend)
    end
  end

  describe '#backend' do
    before { subject.backend = nil }
    after { subject.backend = nil }

    it 'sets the backend' do
      backend = double('Backend')

      subject.backend = backend

      expect(subject.backend).to eql(backend)
    end

    it 'defaults to rails backend' do
      rails = double('Rails')
      cache = double('cache_backend')
      allow(rails).to receive(:cache).and_return(cache)
      stub_const('Rails', rails)

      expect(subject.backend).to eql(cache)
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
