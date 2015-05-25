# encoding: utf-8

describe Cassette::Cache do
  subject do
    c = Class.new
    c.send(:include, Cassette::Cache)
    c.new
  end

  describe 'backend' do
    before { subject.backend = nil }
    after { subject.backend = nil }

    it 'sets the backend' do
      backend = double('Backend')
      subject.backend = backend
      expect(subject.backend).to eql(backend)
    end

    it 'defaults to rails backend' do
      rails = double('Rails')
      allow(rails).to receive(:cache).and_return(rails)
      stub_const('Rails', rails)

      expect(subject.backend).to eql(rails)
    end
  end

  it 'invalidates the cache after the configured number of uses' do
    generator = double('Generator')
    expect(generator).to receive(:generate).twice

    6.times do
      subject.fetch('Generator', max_uses: 5) { generator.generate }
    end
  end
end
