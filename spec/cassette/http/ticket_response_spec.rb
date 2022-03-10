describe Cassette::Http::TicketResponse do
  subject(:ticket_response) { described_class.new(xml_response) }

  let(:xml_response) { fixture('cas/success.xml') }

  describe '#login' do
    subject(:login) { ticket_response.login }

    it { is_expected.to eq('test-user') }

    context "when response isn't successful"  do
      let(:xml_response) { fixture('cas/fail.xml') }

      it { is_expected.to be_nil }
    end
  end

  describe '#name' do
    subject(:name) { ticket_response.name }

    it { is_expected.to eq('Test System') }

    context "when response isn't successful"  do
      let(:xml_response) { fixture('cas/fail.xml') }

      it { is_expected.to be_nil }
    end
  end

  describe '#authorities' do
    subject(:authorities) { ticket_response.authorities }

    it { is_expected.to eq('[CUPOM, AUDITING,]') }

    context "when response isn't successful"  do
      let(:xml_response) { fixture('cas/fail.xml') }

      it { is_expected.to be_nil }
    end
  end

  describe '#extra_attributes' do
    it 'converts the nodes to a hash' do
      expect(ticket_response.extra_attributes['extra']).to eq('value')
    end

    it 'does not change keys' do
      expect(ticket_response.extra_attributes['camelKey']).to eq('camelValue')
    end

    it 'does not include login, name nor authorities' do
      expect(ticket_response.extra_attributes).not_to have_key('login')
      expect(ticket_response.extra_attributes).not_to have_key('name')
      expect(ticket_response.extra_attributes).not_to have_key('authorities')
    end

    context "when response isn't successful"  do
      let(:xml_response) { fixture('cas/fail.xml') }

      it 'is nil' do
        expect(ticket_response.extra_attributes).to be_nil
      end
    end
  end
end
