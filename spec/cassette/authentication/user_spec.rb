# frozen_string_literal: true

describe Cassette::Authentication::User do
  let(:base_authority) do
    Cassette.config.base_authority
  end

  describe '#initialize' do
    context 'without a config' do
      it 'forwards authorities parsing' do
        expect(Cassette::Authentication::Authorities).to receive(:new).with('[CUSTOMERAPI, SAPI]', nil)
        described_class.new(login: 'john.doe', name: 'John Doe', authorities: '[CUSTOMERAPI, SAPI]')
      end
    end

    context 'with a config' do
      it 'forwards authorities parsing passing along the base authority' do
        config = object_double(Cassette.config)

        expect(config).to receive(:base_authority).and_return('TESTAPI')
        expect(Cassette::Authentication::Authorities).to receive(:new).with('[CUSTOMERAPI, SAPI]', 'TESTAPI')

        described_class.new(login: 'john.doe', name: 'John Doe',
                            authorities: '[CUSTOMERAPI, SAPI]', config: config)
      end
    end
  end

  describe '#has_role?' do
    let(:user) do
      described_class.new(login: 'john.doe', name: 'John Doe',
                          authorities: "[#{base_authority}, SAPI, #{base_authority}_CREATE-USER]")
    end

    it 'adds the application prefix to roles' do
      expect(user.has_role?('CREATE-USER')).to be(true)
    end

    it 'ignores role case' do
      expect(user.has_role?('create-user')).to be(true)
    end

    it 'replaces underscores with dashes' do
      expect(user.has_role?('create_user')).to be(true)
    end
  end

  context 'user types' do
    describe '#employee?' do
      it 'returns true when user is an employee' do
        expect(described_class.new(type: 'employee')).to be_employee
        expect(described_class.new(type: 'Employee')).to be_employee
        expect(described_class.new(type: :employee)).to be_employee
        expect(described_class.new(type: 'customer')).not_to be_employee
        expect(described_class.new(type: nil)).not_to be_employee
        expect(described_class.new(type: '')).not_to be_employee
      end
    end

    describe '#customer?' do
      it 'returns true when the user is a customer' do
        expect(described_class.new(type: 'customer')).to be_customer
        expect(described_class.new(type: 'Customer')).to be_customer
        expect(described_class.new(type: :customer)).to be_customer
        expect(described_class.new(type: 'employee')).not_to be_customer
        expect(described_class.new(type: nil)).not_to be_customer
        expect(described_class.new(type: '')).not_to be_customer
      end
    end
  end
end
