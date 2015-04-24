# encoding: utf-8

require 'spec_helper'

RSpec.describe Cassette::Authentication::MultiServiceFilter do
  before do
    allow(Cassette::Authentication).to receive(:validate_ticket)
  end

  describe '.validate_authentication_ticket' do
    before do
      allow(Cassette).to receive(:config) { config }
    end

    let(:config) { OpenStruct.new(YAML.load_file('spec/config.yml')) }

    let(:controller) do
      ControllerMock(described_class).new({}, 'Service-Ticket' => 'le-ticket')
    end

    context 'when config responds to #services' do
      let(:subdomain) { "subdomain.acme.org" }
      let(:not_related) { "acme.org" }

      let(:config) do
        OpenStruct.new(YAML.load_file('spec/config.yml').merge(services: [subdomain]))
      end

      context 'and the authentication service is included in the configuration' do
        before do
          expect(controller).to receive(:authentication_service) { subdomain }
        end

        it 'validates against the service ticket' do
          expect(Cassette::Authentication).to receive(:validate_ticket)
            .with('le-ticket', subdomain)

          controller.validate_authentication_ticket
        end
      end

      context 'and the authentication service is Cassette.config.service' do
        before do
          expect(controller).to receive(:authentication_service) { Cassette.config.service }
          expect(Cassette.config.services).not_to include(Cassette.config.service)
        end

        it 'validates against the service ticket' do
          expect(Cassette::Authentication).to receive(:validate_ticket)
            .with('le-ticket', Cassette.config.service)

          controller.validate_authentication_ticket
        end
      end

      context 'and the authentication service is not included in the configuration' do
        before do
          expect(controller).to receive(:authentication_service) { not_related }
        end

        it 'does not try to validate the ticket' do
          expect(Cassette::Authentication).not_to receive(:validate_ticket)

          expect { controller.validate_authentication_ticket }
            .to raise_error(Cassette::Errors::Forbidden)
        end

        it 'raises a Cassette::Errors::Forbidden error' do
          expect { controller.validate_authentication_ticket }
            .to raise_error(Cassette::Errors::Forbidden)
        end
      end
    end

    context 'when config does not respond to #services' do
      it 'authenticates against #authentication_service' do
        expect(controller).to receive(:authentication_service) { 'overriden.service' }
        expect(Cassette::Authentication).to receive(:validate_ticket).with('le-ticket', 'overriden.service')

        controller.validate_authentication_ticket
      end
    end
  end
end
