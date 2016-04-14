

describe Cassette::Authentication::User do
  let(:base_authority) do
    Cassette.config.base_authority
  end

  describe '#initialize' do
    context 'without a config' do
      it 'forwards authorities parsing' do
        expect(Cassette::Authentication::Authorities).to receive(:new).with('[CUSTOMERAPI, SAPI]', nil)
        Cassette::Authentication::User.new(login: 'john.doe', name: 'John Doe', authorities: '[CUSTOMERAPI, SAPI]')
      end
    end

    context 'with a config' do
      it 'forwards authorities parsing passing along the base authority' do
        config = object_double(Cassette.config)

        expect(config).to receive(:base_authority).and_return('TESTAPI')
        expect(Cassette::Authentication::Authorities).to receive(:new).with('[CUSTOMERAPI, SAPI]', 'TESTAPI')

        Cassette::Authentication::User.new(login: 'john.doe', name: 'John Doe', authorities: '[CUSTOMERAPI, SAPI]', config: config)
      end
    end
  end

  describe '#has_role?' do
    let (:user) do
      Cassette::Authentication::User.new(login: 'john.doe', name: 'John Doe',
                                         authorities: "[#{base_authority}, SAPI, #{base_authority}_CREATE-USER]")
    end

    it 'adds the application prefix to roles' do
      expect(user.has_role?('CREATE-USER')).to eql(true)
    end

    it 'ignores role case' do
      expect(user.has_role?('create-user')).to eql(true)
    end

    it 'replaces underscores with dashes' do
      expect(user.has_role?('create_user')).to eql(true)
    end
  end

  context 'user types' do
    context '#employee?' do
      it 'returns true when user is an employee' do
        expect(Cassette::Authentication::User.new(type: 'employee')).to be_employee
        expect(Cassette::Authentication::User.new(type: 'Employee')).to be_employee
        expect(Cassette::Authentication::User.new(type: :employee)).to be_employee
        expect(Cassette::Authentication::User.new(type: 'customer')).not_to be_employee
        expect(Cassette::Authentication::User.new(type: nil)).not_to be_employee
        expect(Cassette::Authentication::User.new(type: '')).not_to be_employee
      end
    end

    context '#customer?' do
      it 'returns true when the user is a customer' do
        expect(Cassette::Authentication::User.new(type: 'customer')).to be_customer
        expect(Cassette::Authentication::User.new(type: 'Customer')).to be_customer
        expect(Cassette::Authentication::User.new(type: :customer)).to be_customer
        expect(Cassette::Authentication::User.new(type: 'employee')).not_to be_customer
        expect(Cassette::Authentication::User.new(type: nil)).not_to be_customer
        expect(Cassette::Authentication::User.new(type: '')).not_to be_customer
      end
    end
  end
end
