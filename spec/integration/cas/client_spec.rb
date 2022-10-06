# frozen_string_literal: true

RSpec.describe 'Cassette::Client, Cassette::Authentication integration' do
  shared_examples_for 'a Cassette client and validator' do
    let(:config) { raise 'implement config!' }
    let(:client) { Cassette::Client.new(config: config) }
    let(:authentication) { Cassette::Authentication.new(config: config) }

    it 'generates an ST' do
      expect(client.st_for(config.service)).not_to be_blank
    end

    it 'validates an ST, extracting the user' do
      st = client.st_for(config.service)
      user = authentication.ticket_user(st, config.service)

      expect(user).not_to be_blank
      expect(user.login).to eql(config.username)
    end
  end
end
