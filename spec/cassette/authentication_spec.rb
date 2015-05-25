# encoding: utf-8
describe Cassette::Authentication do
  let(:cache) { instance_double(Cassette::Authentication::Cache) }
  let(:http)  { class_double(Cassette) }

  subject(:authentication) do
    Cassette::Authentication.new(cache: cache, http_client: http)
  end

  describe '#ticket_user' do
    subject(:ticket_user) { authentication.ticket_user(ticket) }

    let(:ticket) { 'ticket' }
    let(:cached_value) { 'cached_value' }
    let(:service) { 'test-api.example.org' }

    context 'when cached' do
      before do
        allow(cache).to receive(:fetch_authentication)
          .and_return(cached_value)
      end

      it { is_expected.to eql(cached_value) }
      it 'calls Cache#fetch_authentication with ticket and service' do
        expect(cache).to receive(:fetch_authentication)
          .with(ticket, service)

        ticket_user
      end

      it 'passes a block to Cache#fetch_authentication' do
        expect(cache).to receive(:fetch_authentication) do |*, &block|
          expect(block).to be_present
        end

        ticket_user
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
          expect(ticket_user).to be_nil
        end
      end

      context 'with a successful CAS response' do
        before do
          allow(http).to receive(:post).with(anything, anything)
            .and_return(OpenStruct.new(body: fixture('cas/success.xml')))
        end

        it 'returns an User' do
          expect(ticket_user).to be_instance_of(Cassette::Authentication::User)
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
