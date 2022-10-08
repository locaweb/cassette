# frozen_string_literal: true

require 'spec_helper'

describe Cassette::Client do
  let(:http) { instance_double(Cassette::Http::Request) }
  let(:cache) { instance_double(Cassette::Client::Cache) }
  let(:options) do
    {
      http_client: http,
      cache: cache
    }
  end

  let(:client) do
    described_class.new(options)
  end

  describe '#health_check' do
    subject(:health_check) { client.health_check }

    it 'raises any Error' do
      allow(client).to receive(:st_for).with(anything).and_raise('Failure')

      expect { health_check }.to raise_error('Failure')
    end

    it 'tries to generate a ST' do
      allow(client).to receive(:st_for).with(an_instance_of(String)).and_return('ST-Something')

      expect(health_check).to eq 'ST-Something'
    end
  end

  describe '#tgt' do
    subject(:client_tgt) { client.tgt('user', 'pass', force) }

    context 'with http client interactions' do
      let(:force) { true }
      let(:response) { Faraday::Response.new }

      before do
        allow(cache).to receive(:fetch_tgt).and_yield
        allow(http).to receive(:post) { response }
      end

      it 'extracts the tgt from the Location header' do
        tgt = 'TGT-something'
        allow(response).to receive(:headers).and_return('Location' => "/tickets/#{tgt}")

        expect(client_tgt).to eq tgt
      end

      it 'posts the username and password' do
        client_tgt
        expect(http).to have_received(:post).with(anything, username: 'user', password: 'pass')
      end

      it 'posts to a /v1/tickets uri' do
        client_tgt
        expect(http).to have_received(:post).with(%r{/v1/tickets\z}, instance_of(Hash))
      end
    end

    context 'when tgt is not cached' do
      after do
        Cassette.logger = Logger.new('/dev/null')
      end

      it 'returns the tgt and logs correctly' do
        described_class.cache.backend.clear

        tgt = 'TGT-Something-example'
        response = instance_double('response', headers: { 'Location' => "tickets/#{tgt}" })
        allow(http).to receive(:post).and_return(response)

        logger = spy(:logger)
        Cassette.logger = logger

        client = described_class.new(http_client: http)

        # exercise
        result = client.tgt('user', 'pass')

        # verify
        expect(result).to eq(tgt)
        expect(logger).to have_received(:info).with('TGT cache miss').ordered
        expect(logger).to have_received(:info).with("TGT is #{tgt}").ordered
      end
    end

    context 'with a cached tgt' do
      after do
        Cassette.logger = Logger.new('/dev/null')
      end

      it 'returns the tgt from the cache and logs correctly' do
        described_class.cache.backend.clear

        tgt = 'TGT-Something-example'
        response = instance_double('response', headers: { 'Location' => "tickets/#{tgt}" })
        allow(http).to receive(:post).and_return(response)

        # this first call is to set the cache
        client = described_class.new(http_client: http)
        client.tgt('user', 'pass')

        logger = spy(:logger)
        Cassette.logger = logger
        client = described_class.new(http_client: http)

        # exercise
        result = client.tgt('user', 'pass')

        # verify
        expect(result).to eq(tgt)
        expect(logger).to have_received(:info).with("TGT cache hit, value: '#{tgt}'")
      end

      it 'generates another tgt when the param force is true' do
        described_class.cache.backend.clear

        tgt = 'TGT-Something-example'
        response = instance_double('response', headers: { 'Location' => "tickets/#{tgt}" })
        allow(http).to receive(:post).and_return(response)

        # this first call is to set the cache
        client = described_class.new(http_client: http)
        client.tgt('user', 'pass')

        tgt2 = 'TGT2-Something-example'
        response = instance_double('response', headers: { 'Location' => "tickets/#{tgt2}" })
        allow(http).to receive(:post).and_return(response)

        logger = spy(:logger)
        Cassette.logger = logger
        client = described_class.new(http_client: http)

        # exercise
        force = true
        result = client.tgt('user', 'pass', force)

        # verify
        expect(result).to eq(tgt2)
        expect(logger).to have_received(:info).with('TGT cache miss').ordered
        expect(logger).to have_received(:info).with("TGT is #{tgt2}").ordered
      end
    end
  end

  describe '#st' do
    subject(:client_st) { client.st(tgt_param, service, force) }

    let(:service) { 'example.org' }
    let(:tgt) { 'TGT-Example' }
    let(:st) { 'ST-Something-example' }
    let(:tgt_param) { tgt }

    shared_context 'with http client interactions' do
      let(:force) { true }
      let(:response) { Faraday::Response.new }

      before do
        allow(cache).to receive(:fetch_st).and_yield
        allow(http).to receive(:post) { response }
      end

      it 'extracts the tgt from the Location header' do
        allow(response).to receive(:body) { st }

        expect(client_st).to eq st
      end

      it 'posts the service' do
        client_st

        expect(http).to have_received(:post).with(anything, service: service)
      end

      it 'posts to the tgt uri' do
        client_st

        expect(http).to have_received(:post).with(%r{/#{tgt}\z}, instance_of(Hash))
      end
    end

    context 'when tgt is a string' do
      let(:tgt_param) { tgt }

      it_behaves_like 'with http client interactions'
    end

    context 'when tgt is a callable' do
      let(:tgt_param) { -> { tgt } }

      it_behaves_like 'with http client interactions'
    end

    context 'with cache control' do
      let(:cache_control) { subject }

      before do
        allow(cache).to receive(:fetch_st).with(tgt, service, hash_including(force: force))
                                          .and_return(st)
      end

      shared_examples 'with controlling the force' do
        it { is_expected.to eq st }

        it 'forwards force to the cache' do
          cache_control

          expect(cache).to have_received(:fetch_st).with(tgt, service, hash_including(force: force))
        end
      end

      context 'when not using the force' do
        let(:force) { false }

        include_context 'with controlling the force'
      end

      context 'when using the force' do
        let(:force) { true }

        include_context 'with controlling the force'
      end
    end
  end

  describe '#st_for' do
    subject(:client_st_for) { client.st_for(service) }

    let(:service) { 'example.org' }
    let(:cached_tgt) { 'TGT-Something' }
    let(:tgt)  { 'TGT-Something-NEW' }
    let(:st) { 'ST-For-Something' }

    context 'when tgt and st are not cached' do
      before do
        allow(cache).to receive(:fetch_tgt).with(hash_including(force: false)).and_yield
        allow(cache).to receive(:fetch_st).with(tgt, service, hash_including(force: false)).and_yield

        allow(http).to receive(:post)
          .with(%r{/v1/tickets\z}, username: Cassette.config.username, password: Cassette.config.password)
          .and_return(tgt_response)

        allow(http).to receive(:post).with(%r{/v1/tickets/#{tgt}\z}, service: service)
                                     .and_return(st_response)
      end

      let(:st_response) { Faraday::Response.new(body: st) }
      let(:tgt_response) { Faraday::Response.new(response_headers: { 'Location' => "/v1/tickets/#{tgt}" }) }

      it 'returns the generated st' do
        expect(client_st_for).to eq st
      end

      it 'generates an ST' do
        client_st_for

        expect(http).to have_received(:post).with(%r{/v1/tickets/#{tgt}\z}, service: service)
      end

      it 'generates a TGT' do
        client_st_for

        expect(http).to have_received(:post)
          .with(%r{/v1/tickets\z}, username: Cassette.config.username, password: Cassette.config.password)
      end
    end

    context 'when tgt is cached but st is not' do
      let(:cached_tgt) { subject }
      let(:st_response) { Faraday::Response.new(body: st) }

      before do
        allow(cache).to receive(:fetch_tgt).with(hash_including(force: false)).and_return(tgt)
        allow(cache).to receive(:fetch_st).with(tgt, service, hash_including(force: false)).and_yield

        allow(http).to receive(:post).with(%r{/v1/tickets/#{tgt}\z}, service: service)
                                     .and_return(st_response)
      end

      it 'returns the generated st' do
        expect(cached_tgt).to eq st
      end

      it 'generates an ST' do
        cached_tgt

        expect(http).to have_received(:post).with(%r{/v1/tickets/#{tgt}\z}, service: service)
      end
    end

    context 'when st is cached' do
      let(:cached_st) { subject }

      before do
        allow(cache).to receive(:fetch_st).with(tgt, service, hash_including(force: false)).and_return(st)
        allow(cache).to receive(:fetch_tgt).and_return(tgt)
      end

      it 'returns the cached value' do
        expect(cached_st).to eq st
      end
    end

    context 'when tgt is expired' do
      let(:expired_tgt) { subject }
      let(:tgt_response) { Faraday::Response.new(response_headers: { 'Location' => "/v1/tickets/#{tgt}" }) }
      let(:st_response) { Faraday::Response.new(body: st) }

      before do
        allow(cache).to receive(:fetch_tgt).with(hash_including(force: false)).and_return(cached_tgt)
        allow(cache).to receive(:fetch_tgt).with(hash_including(force: true)).and_yield
        allow(cache).to receive(:fetch_st).and_yield

        allow(http).to receive(:post).with(%r{/v1/tickets/#{cached_tgt}\z}, service: service)
                                     .and_raise(Cassette::Errors::NotFound)

        allow(http).to receive(:post)
          .with(%r{/v1/tickets\z}, username: Cassette.config.username, password: Cassette.config.password)
          .and_return(tgt_response)

        allow(http).to receive(:post).with(%r{/v1/tickets/#{tgt}\z}, service: service)
                                     .and_return(st_response)
      end

      it 'calls #fetch_st twice' do
        expired_tgt

        expect(cache).to have_received(:fetch_st).twice
      end

      it 'calls #fetch_tgt without forcing' do
        expired_tgt

        expect(cache).to have_received(:fetch_tgt).with(force: false)
      end

      it 'calls #fetch_tgt forcing' do
        expired_tgt

        expect(cache).to have_received(:fetch_tgt).with(force: true)
      end

      it 'tries to generate a ST with the expired TGT' do
        expired_tgt

        expect(http).to have_received(:post).with(%r{/v1/tickets/#{cached_tgt}\z}, service: service)
      end

      it 'retries to generate a ST with the new TGT' do
        expired_tgt

        expect(http).to have_received(:post).with(%r{/v1/tickets/#{tgt}\z}, service: service)
      end

      it 'returns a brand new tgt' do
        expect(expired_tgt).to eq st
      end
    end
  end
end
