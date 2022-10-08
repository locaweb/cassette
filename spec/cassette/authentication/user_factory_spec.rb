# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cassette::Rubycas::UserFactory do
  let(:mod) do
    Module.new do
      include Cassette::Rubycas::UserFactory
      extend self
    end
  end

  describe '#from_session' do
    subject do
      mod.from_session(session)
    end

    let(:session) do
      name = Faker.name

      {
        cas_user: Faker::Internet.user_name(name),
        cas_extra_attributes: {
          email: Faker::Internet.email(name),
          type: 'Customer',
          authorities: '[CASTEST_ADMIN]'
        }
      }
    end

    let(:attributes) do
      session[:cas_extra_attributes]
    end

    context 'with default attributes' do
      its(:login) { is_expected.to eq(session[:cas_user]) }
      its(:name) { is_expected.to eq(attributes[:name]) }
      its(:email) { is_expected.to eq(attributes[:email]) }
      its(:type) { is_expected.to eq(attributes[:type].downcase) }
      it { is_expected.to be_customer }
      it { is_expected.not_to be_employee }
    end

    context 'when key cas_extra_attributes is string' do
      let(:session) do
        name = Faker.name

        {
          cas_user: Faker::Internet.user_name(name),
          cas_extra_attributes: {
            'email' => Faker::Internet.email(name),
            'type' => 'Customer',
            'authorities' => '[CASTEST_ADMIN]'
          }
        }
      end

      its(:login) { is_expected.to eq(session[:cas_user]) }
      its(:name) { is_expected.to eq(attributes['name']) }
      its(:email) { is_expected.to eq(attributes['email']) }
      its(:type) { is_expected.to eq(attributes['type'].downcase) }
      it { is_expected.to be_customer }
      it { is_expected.not_to be_employee }
    end
  end
end
