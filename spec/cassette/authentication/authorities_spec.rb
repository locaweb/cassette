

describe Cassette::Authentication::Authorities do
  subject do
    Cassette::Authentication::Authorities
  end

  describe '#has_role?' do
    let(:input) { "[#{Cassette.config.base_authority}, SAPI, #{Cassette.config.base_authority}_CREATE-USER]" }
    let(:authorities) { subject.parse(input) }

    it 'adds the application prefix to roles' do
      expect(authorities.has_role?('CREATE-USER')).to eql(true)
    end

    it 'ignores role case' do
      expect(authorities.has_role?('create-user')).to eql(true)
    end

    it 'replaces underscores with dashes' do
      expect(authorities.has_role?('create_user')).to eql(true)
    end
  end

  context 'with a defined base authority' do
    let(:base_authority) { 'SOMEAPI' }

    it 'stores the base authority' do
      input = 'CUSTOMERAPI'
      expect(subject.parse(input, base_authority).base).to eql(base_authority)
    end

    describe '#has_role?' do
      let(:input) { "[#{Cassette.config.base_authority}_TEST2, SOMEAPI_TEST]" }

      it 'returns true for a role that is using the base authority' do
        expect(subject.parse(input, base_authority)).to have_role(:test)
      end

      it 'returns false for a role that is not using the base authority' do
        expect(subject.parse(input, base_authority)).not_to have_role(:test2)
      end
    end
  end

  context 'CAS authorities parsing' do
    it 'handles single authority' do
      input = 'CUSTOMERAPI'
      expect(subject.parse(input).authorities).to eq(%w(CUSTOMERAPI))
    end

    it 'handles multiple authorities with surrounding []' do
      input = '[CUSTOMERAPI, SAPI]'
      expect(subject.parse(input).authorities).to eq(%w(CUSTOMERAPI SAPI))
    end

    it 'ignores whitespace in multiple authorities' do
      input = '[CUSTOMERAPI,SAPI]'
      expect(subject.parse(input).authorities).to eq(%w(CUSTOMERAPI SAPI))
    end

    it 'returns an empty array when input is nil' do
      expect(subject.parse(nil).authorities).to eq([])
    end
  end

  context 'with authentication disabled' do
    before { ENV['NOAUTH'] = 'true' }
    after { ENV.delete('NOAUTH') }
    subject { Cassette::Authentication::Authorities.new('[]') }

    it '#has_role? returns true for every role' do
      expect(subject.authorities).to be_empty
      expect(subject.has_role?(:can_manage)).to eql(true)
    end

    it '#has_raw_role? returns true for every role' do
      expect(subject.authorities).to be_empty
      expect(subject.has_raw_role?('SAPI_CUSTOMER-CREATOR')).to eql(true)
    end
  end
end
