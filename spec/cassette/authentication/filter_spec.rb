# encoding: utf-8



describe Cassette::Authentication::Filter do
  before do
    allow(Cassette::Authentication).to receive(:validate_ticket)
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
    let(:controller) { ControllerMock(described_class).new }
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
    let(:controller) { ControllerMock(described_class).new }
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
        let(:controller) { ControllerMock(described_class).new }

        it_behaves_like 'controller without authentication'
      end

      context 'and a ticket header' do
        let(:controller) do
          ControllerMock(described_class).new({}, 'Service-Ticket' => 'le ticket')
        end

        it_behaves_like 'controller without authentication'
      end

      context 'and a ticket param' do
        let(:controller) do
          ControllerMock(described_class).new(ticket: 'le ticket')
        end

        it_behaves_like 'controller without authentication'
      end
    end

    context 'when accepts_authentication_service? returns false' do
      let(:controller) do
        ControllerMock(described_class).new(ticket: 'le ticket')
      end

      before do
        expect(controller).to receive(:accepts_authentication_service?)
          .with(Cassette.config.service) { false }
      end

      it 'raises a Cassette::Errors::Forbidden' do
        expect { controller.validate_authentication_ticket }
          .to raise_error(Cassette::Errors::Forbidden)
      end
    end

    context 'when accepts_authentication_service? returns true' do
      before do
        expect(controller).to receive(:accepts_authentication_service?).with(anything) { true }
      end

      context 'with a ticket in the query string *AND* headers' do
        let(:controller) do
          ControllerMock(described_class).new({ 'ticket' => 'le other ticket' },
                                              'Service-Ticket' => 'le ticket')
        end

        it 'should send only the header ticket to validation' do
          controller.validate_authentication_ticket
          expect(Cassette::Authentication).to have_received(:validate_ticket).with('le ticket', Cassette.config.service)
        end
      end

      context 'with a ticket in the query string' do
        let(:controller) do
          ControllerMock(described_class).new('ticket' => 'le ticket')
        end

        it 'should send the ticket to validation' do
          controller.validate_authentication_ticket
          expect(Cassette::Authentication).to have_received(:validate_ticket).with('le ticket', Cassette.config.service)
        end
      end

      context 'when #authentication_service is overriden' do
        let(:controller) do
          mod = Module.new do
            def authentication_service
              "subdomain.#{Cassette.config.service}"
            end
          end

          ControllerMock(described_class, mod).new({}, 'Service-Ticket' => 'le ticket')
        end

        it 'validates with the overriden value and not the config' do
          controller.validate_authentication_ticket

          expect(Cassette::Authentication).to have_received(:validate_ticket)
            .with('le ticket', "subdomain.#{Cassette.config.service}")
        end
      end

      context 'with a ticket in the Service-Ticket header' do
        let(:controller) do
          ControllerMock(described_class).new({}, 'Service-Ticket' => 'le ticket')
        end

        it 'sends the ticket to validation' do
          controller.validate_authentication_ticket

          expect(Cassette::Authentication).to have_received(:validate_ticket)
            .with('le ticket', Cassette.config.service)
        end
      end
    end
  end

  describe '#accepts_authentication_service?' do
    let(:controller) do
      ControllerMock(described_class).new(ticket: 'le ticket')
    end

    before do
      allow(Cassette).to receive(:config) { config }
    end

    subject { controller.accepts_authentication_service?(service) }

    context 'when config responds to #services' do
      let(:subdomain) { "subdomain.acme.org" }
      let(:not_related) { "acme.org" }

      let(:config) do
        OpenStruct.new(YAML.load_file('spec/config.yml').merge(services: [subdomain]))
      end

      context 'and the authentication service is included in the configuration' do
        let(:service) { subdomain }

        it { is_expected.to eq true }
      end

      context 'and the authentication service is Cassette.config.service' do
        let(:service) { Cassette.config.service }

        it { is_expected.to eq true }
      end

      context 'and the authentication service is not included in the configuration' do
        let(:service) { not_related }

        it { is_expected.to eq false }
      end
    end
  end
end
