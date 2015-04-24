# encoding: utf-8

require 'spec_helper'

describe Cassette::Authentication do
  let(:cache) { instance_double(Cassette::Authentication::Cache) }
  let(:http)  { class_double(Cassette) }

  subject do
    Cassette::Authentication.new(cache: cache, http_client: http)
  end

  describe '#ticket_user' do
    context 'when cached' do
      it 'returns the cached value when cached' do
        cached = double('cached')

        expect(cache).to receive(:fetch_authentication) do |ticket, &block|
          expect(ticket).to eql('ticket')
          expect(block).to be_present
          cached
        end

        expect(subject.ticket_user('ticket')).to eql(cached)
      end
    end

    context 'when not cached' do
      before do
        expect(cache).to receive(:fetch_authentication) do |_ticket, &block|
          block.call
        end
      end

      it 'raises a Forbidden exception on any exceptions' do
        allow(http).to receive(:post).with(anything, anything).and_raise(Cassette::Errors::BadRequest)
        expect { subject.ticket_user('ticket') }.to raise_error(Cassette::Errors::Forbidden)
      end

      context 'with a failed CAS response' do
        before do
          allow(http).to receive(:post).with(anything, anything)
            .and_return(OpenStruct.new(body: fixture('cas/fail.xml')))
        end

        it 'returns nil' do
          expect(subject.ticket_user('ticket')).to be_nil
        end
      end

      context 'with a successful CAS response' do
        before do
          allow(http).to receive(:post).with(anything, anything)
            .and_return(OpenStruct.new(body: fixture('cas/success.xml')))
        end

        it 'returns an User' do
          expect(subject.ticket_user('ticket')).to be_instance_of(Cassette::Authentication::User)
        end
      end
    end
  end

  describe '#validate_ticket' do
    it 'raises a authorization required error when no ticket is provided' do
      expect { subject.validate_ticket(nil) }.to raise_error(Cassette::Errors::AuthorizationRequired)
    end

    it 'raises a authorization required error when ticket is blank' do
      expect { subject.validate_ticket('') }.to raise_error(Cassette::Errors::AuthorizationRequired)
    end

    it 'raises a forbidden error when the associated user is not found' do
      expect(subject).to receive(:ticket_user).with('ticket', Cassette.config.service).and_return(nil)
      expect { subject.validate_ticket('ticket') }.to raise_error(Cassette::Errors::Forbidden)
    end

    it 'returns the associated user' do
      user = double('User')
      expect(subject).to receive(:ticket_user).with('ticket', Cassette.config.service).and_return(user)
      expect(subject.validate_ticket('ticket')).to eql(user)
    end
  end
end
