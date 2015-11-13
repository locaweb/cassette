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
end
