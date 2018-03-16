require 'rails_helper'

RSpec.describe Repo::PullRequests, :vcr do 
  let(:repo) {GithubAdapter.new.owned_repos.recent_repos.first}
  let(:pulls) { repo.pull_requests}
  
  describe "on initialization", :vcr do
    it "is assigned a collection if pull_requests" do
      expect(pulls.pulls).to be_an_instance_of Array
    end

    it "assigns a date to compare old pulls against" do
      expect(Date.parse(pulls.since)).not_to be nil
    end

    it "is assinged the name of the repo it came from. " do
      expect(pulls.repo).to eq repo.full_name
    end
  end

  describe "oauth_client", :vcr do
    it "returns a oath github client" do
      expect(pulls.oauth_client).to be_an_instance_of Octokit::Client
    end

    it "returns a client with a valid acces token" do
      expect(pulls.oauth_client.access_token).to_not be nil
    end
  end

  describe "comments", :vcr do
    it "return an array of sawyer::resource" do
      expect(pulls.comments.first).to be_an_instance_of Sawyer::Resource
    end
  end

  describe "comments_by_date", :vcr do
    before do
      @groups = pulls.comments_by_date
    end

    it "returns a hash" do
      expect(@groups).to be_an_instance_of Hash
    end

    it "the keys are an acceptable date" do
      key = @groups.keys.first
      expect(Date.parse(key)).to_not be nil
    end

  end

  describe "count_of_comments_by_date", :vcr do
    before do
      @groups = pulls.count_of_comments_by_date
    end
    
    it "returns a hash" do
      expect(@groups).to be_an_instance_of Hash
    end

    it "the keys are an acceptable date" do
      key = @groups.keys.first
      expect(Date.parse(key)).to_not be nil
    end

  end

  describe "create_pulls", :vcr do
    it "returns an array of pull object" do
      api_response = repo.client.pull_requests(repo.id, state: 'all', since: two_weeks_ago)
      expect(pulls.create_pulls(api_response).first).to be_an_instance_of Repo::PullRequests::Pull
    end
  end

  describe "date_grouped_data", :vcr do
    it "returns a merged hash of pull request data" do
      expect(pulls.date_grouped_data).to be_an_instance_of Hash
    end

    it "has a parsable date as keys" do
      key = pulls.date_grouped_data.keys.first
      expect(Date.parse(key)).to_not be nil
    end
  end

  describe "recent_pulls", :vcr do
    it "returns a pull request object" do
      expect(pulls.recent_pulls).to be_an_instance_of Repo::PullRequests
    end

    it "only has pulls within the last two weeks" do
      expect(pulls.recent_pulls.pulls.first.recent?).to be(true)
    end
  end

  describe "closed_pulls", :vcr do
    it "returns an array of pull request" do
      expect(pulls.closed_pulls.first).to be_an_instance_of Repo::PullRequests::Pull
    end
  end

  describe "grouped_per_closed", :vcr do
    it "returns a hash" do
      expect(pulls.grouped_per_closed).to be_an_instance_of Hash
    end

    it "has a parsable date as keys" do
      key = pulls.grouped_per_closed.keys.first
      expect(Date.parse(key)).to_not be nil
    end

  end

  describe "count_for_closed", :vcr do
    it "returns a condensed hash" do
      expect(pulls.count_for_closed).to be_an_instance_of Hash
    end

  end

  describe "grouped_per_created_at", :vcr do
     it "returns a hash" do
      expect(pulls.grouped_per_created_at).to be_an_instance_of Hash
    end

    it "has keys parsable as a date" do
      key = pulls.grouped_per_created_at.keys.first
      expect(Date.parse(key)).to_not be nil
    end
  end

  describe "count_for_created_at", :vcr do
    it "returns a condensed hash" do
      expect(pulls.count_for_created_at).to be_an_instance_of Hash
    end
  end

end