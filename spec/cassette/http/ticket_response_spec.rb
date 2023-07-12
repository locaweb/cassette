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

  describe '#attributes' do
    subject(:attributes) { ticket_response.attributes }

    context 'when response is successful' do
      let(:xml_response) { fixture('cas/success.xml') }

      it 'returns the attributes not already extracted' do
        expect(subject).to eq('type' => 'System', 'attribute' => 'something')
      end
    end

    context 'when response is not successful' do
      let(:xml_response) { fixture('cas/fail.xml') }

      it { is_expected.to be_nil }
    end
  end
end
