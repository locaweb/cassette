# encoding: utf-8

require "spec_helper"

RSpec.describe "Cassette::Client, Cassette::Authentication integration" do
  shared_examples_for "a Cassette client and validator" do
    let(:config) { raise "implement config!" }
    let(:client) { Cassette::Client.new(config: config) }
    let(:authentication) { Cassette::Authentication.new(config: config) }

    it "generates an ST" do
      expect(client.st_for(config.service)).not_to be_blank
    end

    it "validates an ST, extracting the user" do
      st = client.st_for(config.service)

      expect(user = authentication.ticket_user(st, config.service)).not_to be_blank
      expect(user.login).to eql(config.username)
    end
  end

  context "with a configuration" do
    # it_behaves_like "a Cassette client and validator" do
    #   let(:config) do
    #     OpenStruct.new(
    #       username: "test",
    #       password: "secret",
    #       base: "https://cas.example.org",
    #       base_authority: "API"
    #     )
    #   end
    # end
  end

  context "with a another configuration" do
    # it_behaves_like "a Cassette client and validator" do
    #   let(:config) do
    #     OpenStruct.new(
    #       username: "test.user",
    #       password: "anothersecret",
    #       base: "https://anothercas.example.org",
    #       base_authority: "SYSTEM"
    #     )
    #   end
    # end
  end
end
