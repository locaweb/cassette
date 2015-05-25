

describe Cassette do
  let(:uri) { 'http://example.org/' }
  let(:response) do
    Faraday.new do |builder|
      builder.adapter :test do |stub|
        stub.post(uri, 'ping=pong') do |env|
          headers = env.request_headers
          [200, {}, '{ok: true}']
        end
      end
    end
  end

  let(:failed_response) do
    Faraday.new do |builder|
      builder.adapter :test do |stub|
        stub.post(uri, 'ping=pong') do |env|
          headers = env.request_headers
          [500, {}, '{ok: false}']
        end
      end
    end
  end

  describe '.new_request' do
    it 'returns an instance' do
      # damn coverage
      expect(Cassette.new_request(uri, 5)).to be_instance_of(Faraday::Connection)
    end
  end

  describe '.post' do
    it 'forwards requests' do
      allow(Cassette).to receive(:new_request).with(uri, 5).and_return(response)
      Cassette.post(uri, { ping: :pong }, 5)
    end

    it 'raises an exception when failed' do
      allow(Cassette).to receive(:new_request).with(uri, 5).and_return(failed_response)
      expect { Cassette.post(uri, { ping: :pong }, 5) }.to raise_error(Cassette::Errors::InternalServerError)
    end
  end

  def keeping_logger(&block)
    original_logger = Cassette.logger
    block.call
    Cassette.logger = original_logger
  end

  describe '.logger' do
    it 'returns a default instance' do
      expect(Cassette.logger).not_to be_nil
      expect(Cassette.logger.is_a?(Logger)).to eql(true)
    end

    it 'returns rails logger when Rails is available' do
      keeping_logger do
        Cassette.logger = nil
        rails = double('Rails')
        expect(rails).to receive(:logger).and_return(rails).at_least(:once)
        stub_const('Rails', rails)
        expect(Cassette.logger).to eql(rails)
      end
    end
  end

  describe '.logger=' do
    let(:logger) { Logger.new(STDOUT) }
    it 'defines the logger instance' do
      keeping_logger do
        Cassette.logger = logger
        expect(Cassette.logger).to eq(logger)
      end
    end
  end
end
