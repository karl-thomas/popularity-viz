require 'rails_helper' 

RSpec.describe Repo::PullRequests::Pull, :vcr do
  let(:repo) { GithubAdapter.new.owned_repos.first }
  let(:pull) { repo.pull_requests.pulls[0]}


  describe "recent?", :vcr do
    it "returns a boolean" do
      expect(pull.recent?).to be(true).or(false)
    end
  end

  describe "closed?", :vcr do
    it "returns a boolean" do
      expect(pull.closed?).to be(true).or(false)
    end

    it "returns true when the pull_request is closed" do
      expect(pull.closed?).to be true
    end
  end

  describe "recently_created?", :vcr do
    it "returns a boolean" do
      expect(pull.recently_created?).to be(true).or(false)
    end
  end

  describe "recently_closed?", :vcr do
    it "returns a boolean" do
      expect(pull.recently_closed?).to be(true).or(false)
    end
  end


end