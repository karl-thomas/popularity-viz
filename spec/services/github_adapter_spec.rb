require 'rails_helper'

RSpec.describe GithubAdapter do
  let(:adapter) { GithubAdapter.new }
  context "on initialization" do
    it "has a ocktokit client with application auth" do 
      expect(adapter.client.client_id).to eq test_github_client_id
    end

    it "has a user assigned to it" do 
      expect(adapter.user).to eq github_login
    end
  end

  describe "#two_weeks_ago" do
    it "returns the date two weeks ago, formatted as a string" do
      expect(adapter.two_weeks_ago).to_not be 2.weeks.ago
      expect(adapter.two_weeks_ago).to be_an_instance_of String
    end
  end

  describe "#profile" do
    it "calls the github api with a request for a profile", :vcr do
      adapter.profile
      assert_requested :get, github_url("/users/#{github_login}")
    end

    it "assigns a profile instance variable", :vcr do
      adapter.profile
      expect(adapter.instance_variable_get(:@profile)).to_not be nil
    end

    it "returns the profile of this adapters #user", :vcr do
      response = adapter.profile
      user = adapter.user
      expect(response[:login]).to eq(user)
    end

  end
end
