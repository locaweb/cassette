# frozen_string_literal: true

describe Cassette::Http::Request do
  subject(:request) { described_class }

  describe '.post' do
    subject(:post) { request.post(path, payload) }

    let(:uri) { "#{Cassette.config.base}#{path}" }
    let(:path) { '/something' }
    let(:payload) { { ping: :pong } }
    let(:response) do
      {
        headers: { 'Content-Type' => 'application/json' },
        body: { ok: true }.to_json,
        status: 200
      }
    end

    before { stub_request(:post, uri).to_return(response) }

    it 'performs a http post request with the proper params' do
      post

      expect(a_request(:post, uri).with(body: 'ping=pong')).to have_been_made
    end

    it do
      expect(subject).to have_attributes(
        headers: { 'Content-Type' => 'application/json' },
        body: '{"ok":"true"}',
        status: 200
      )
    end

    context 'when response has an error status code' do
      let(:response) { { status: 500 } }

      it 'raises an exception' do
        expect { post }.to raise_error(Cassette::Errors::InternalServerError)
      end
    end
  end
end
