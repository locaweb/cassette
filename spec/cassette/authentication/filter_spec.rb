# encoding: utf-8

require 'spec_helper'
require 'active_support/core_ext/hash/indifferent_access'

describe Cassette::Authentication::Filter do
  before do
    allow(Cassette::Authentication).to receive(:validate_ticket)
  end

  class ControllerMock
    attr_accessor :params, :request, :current_user
    def self.before_filter(*); end
    include Cassette::Authentication::Filter

    def initialize(params = {}, headers = {})
      self.params = params.with_indifferent_access
      self.request = OpenStruct.new(headers: headers.with_indifferent_access)
    end
  end

  shared_context 'with NOAUTH' do
    before do
      ENV['NOAUTH'] = 'yes'
    end

    after do
      ENV.delete('NOAUTH')
    end
  end

  describe '#validate_raw_role!' do
    let(:controller) { ControllerMock.new }
    let(:current_user) { instance_double(Cassette::Authentication::User) }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    it_behaves_like 'with NOAUTH' do
      it 'never checks the role' do
        expect(current_user).not_to receive(:has_raw_role?)
        controller.validate_raw_role!(:something)
      end

      it 'does not raise error' do
        expect { controller.validate_raw_role!(:something) }.not_to raise_error
      end
    end

    it 'forwards to current_user' do
      role = instance_double(String)

      expect(current_user).to receive(:has_raw_role?).with(role).and_return(true)
      controller.validate_raw_role!(role)
    end

    it 'raises a Cassette::Errors::Forbidden when current_user does not have the role' do
      role = instance_double(String)

      expect(current_user).to receive(:has_raw_role?).with(role).and_return(false)
      expect { controller.validate_raw_role!(role) }.to raise_error(Cassette::Errors::Forbidden)
    end
  end

  describe '#validate_role!' do
    let(:controller) { ControllerMock.new }
    let(:current_user) { instance_double(Cassette::Authentication::User) }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    it_behaves_like 'with NOAUTH' do
      it 'never checks the role' do
        expect(current_user).not_to receive(:has_role?)
        controller.validate_role!(:something)
      end

      it 'does not raise error' do
        expect { controller.validate_role!(:something) }.not_to raise_error
      end
    end

    it 'forwards to current_user' do
      role = instance_double(String)

      expect(current_user).to receive(:has_role?).with(role).and_return(true)
      controller.validate_role!(role)
    end

    it 'raises a Cassette::Errors::Forbidden when current_user does not have the role' do
      role = instance_double(String)

      expect(current_user).to receive(:has_role?).with(role).and_return(false)
      expect { controller.validate_role!(role) }.to raise_error(Cassette::Errors::Forbidden)
    end
  end


  describe '#validate_authentication_ticket' do
    shared_examples_for 'controller without authentication' do
      it 'does not validate tickets' do
        controller.validate_authentication_ticket
        expect(Cassette::Authentication).not_to have_received(:validate_ticket)
      end

      it 'sets current_user' do
        controller.validate_authentication_ticket
        expect(controller.current_user).to be_present
      end
    end

    it_behaves_like 'with NOAUTH' do
      context 'and no ticket' do
        let(:controller) { ControllerMock.new }

        it_behaves_like 'controller without authentication'
      end

      context 'and a ticket header' do
        let(:controller) do
          ControllerMock.new({}, 'Service-Ticket' => 'le ticket')
        end

        it_behaves_like 'controller without authentication'
      end

      context 'and a ticket param' do
        let(:controller) do
          ControllerMock.new(ticket: 'le ticket')
        end

        it_behaves_like 'controller without authentication'
      end
    end

    context 'with a ticket in the query string *AND* headers' do
      let(:controller) do
        ControllerMock.new({ 'ticket' => 'le other ticket' }, 'Service-Ticket' => 'le ticket')
      end

      it 'should send only the header ticket to validation' do
        controller.validate_authentication_ticket
        expect(Cassette::Authentication).to have_received(:validate_ticket).with('le ticket', Cassette.config.service)
      end
    end

    context 'with a ticket in the query string' do
      let(:controller) do
        ControllerMock.new('ticket' => 'le ticket')
      end

      it 'should send the ticket to validation' do
        controller.validate_authentication_ticket
        expect(Cassette::Authentication).to have_received(:validate_ticket).with('le ticket', Cassette.config.service)
      end
    end

    context 'with a ticket in the Service-Ticket header' do
      let(:controller) do
        ControllerMock.new({}, 'Service-Ticket' => 'le ticket')
      end

      it 'should send the ticket to validation' do
        controller.validate_authentication_ticket
        expect(Cassette::Authentication).to have_received(:validate_ticket).with('le ticket', Cassette.config.service)
      end
    end
  end
end
