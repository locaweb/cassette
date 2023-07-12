

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

        Cassette::Authentication::User.new(login: 'john.doe', name: 'John Doe',
                                           authorities: '[CUSTOMERAPI, SAPI]', config: config)
      end
    end

    context 'attributes' do
      it 'takes login from the attributes' do
        user = described_class.new(login: 'john.doe')

        expect(user.login).to eql('john.doe')
      end

      it 'takes name from the attributes' do
        user = described_class.new(name: 'John Doe')

        expect(user.name).to eql('John Doe')
      end
    end
  end

  describe '#attribute' do
    it 'returns attributes given to the user' do
      user = described_class.new(
        login: 'john.doe',
        name: 'John Doe',
        attributes: { 'attribute' => 'something' }
      )

      expect(user.attribute('attribute')).to eql('something')
    end

    it 'retuns nil for attributes not given to the user' do
      user = described_class.new(
        login: 'john.doe',
        name: 'John Doe',
        attributes: { 'attribute' => 'something' }
      )

      expect(user.attribute('other_attribute')).to be_nil
    end

    it 'does not return attributes that are already extracted' do
      user = described_class.new(
        login: 'john.doe',
        name: 'John Doe',
        attributes: { 'attribute' => 'something' }
      )

      expect(user.attribute('login')).to be_nil
    end
  end

  describe '#has_role?' do
    let(:user) do
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
