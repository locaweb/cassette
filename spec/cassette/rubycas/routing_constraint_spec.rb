# frozen_string_literal: true

require 'spec_helper'

describe Cassette::Rubycas::RoutingConstraint do
  describe '#matches?' do
    subject(:matches) { constraint.matches?(request) }

    let(:request) do
      OpenStruct.new(session: session)
    end
    let(:session) do
      {
        cas_user: 'test.user',
        cas_extra_attributes: {
          cn: 'test user',
          email: 'test.user@example.org'
        }
      }
    end

    let(:user) { instance_double(Cassette::Authentication::User) }
    let(:constraint) { described_class.new(role, options) }

    before do
      allow(constraint).to receive(:from_session).with(session).and_return(user)
    end

    context 'with no options' do
      let(:role) { :admin }
      let(:options) { {} }
      let(:has_role) { true }

      before do
        allow(user).to receive(:has_role?).with(role).and_return(has_role)
      end

      it 'checks the User role' do
        matches
        expect(user).to have_received(:has_role?).with(role)
      end

      context 'when user has the role' do
        let(:has_role) { true }

        it { is_expected.to eq(true) }
      end

      context 'when user does not have the role' do
        let(:has_role) { false }

        it { is_expected.to eq(false) }
      end
    end

    context 'when options[:raw] = true' do
      let(:role) { 'API_ADMIN' }
      let(:options) { { raw: true } }
      let(:has_role) { true }

      before do
        allow(user).to receive(:has_raw_role?).with(role).and_return(has_role)
      end

      it 'checks the User role' do
        matches
        expect(user).to have_received(:has_raw_role?).with(role)
      end

      context 'when user has the role' do
        let(:has_role) { true }

        it { is_expected.to eq(true) }
      end

      context 'when user does not have the role' do
        let(:has_role) { false }

        it { is_expected.to eq(false) }
      end
    end
  end
end
