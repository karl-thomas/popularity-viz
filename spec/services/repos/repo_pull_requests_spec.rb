require 'rails_helper'

RSpec.describe Rails::PullRequests do 
  let(:repo) {GithubAdapter.new.owned_repos.recent_repos.first}
  let(:pulls) { repo.pull_requests}
  describe "on initialization" do
    it "is assigned a collection if pull_requests" do
      expect(pulls.pulls).to be_an_instance_of Array
    end

    it "assigns a date to compare old pulls against" do
      expect(pulls.since).to be_an_instance_of Integer
    end

    it "is assinged the name of the repo it came from. " do
      expect(pulls.repo).to eq repo.full_name
    end
  end

  describe "oauth_client" do
    it "returns a oath github client" do
      expect(pulls.oauth_client).to be_an_instance_of Octokit::Client
    end

    it "returns a client with a valid acces token" do
      expect(pulls.oauth_client.access_token).to_not be nil
    end
  end

  describe "comments" do
    it "makes an api request to github for issue comments" do
      pulls.comments
      request_uri = "/repos/#{repo.full_name}/commits?author=#{github_login}&#{auth_client_params}&per_page=100" + since
      assert_requested :get, github_url(request_uri)
    end

    it "return an array of sawyer::resource" do
      expect(pulls.comments.first).to be_an_instance_of Sawyer::Resource
    end
  end

  describe "comments_by_date" do
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

  describe "count_of_comments_by_date" do

  end

  describe "create_pulls" do
    it "returns an array of pull object" do
      api_response = repo.client.pull_requests(repo.id, state: 'all', since: two_weeks_ago)
      expect(pulls.create_pulls.first).to be_an_instance_of Repo::PullRequests::Pull
    end
  end

  describe "date_grouped_data" do

  end

  describe "recent_pulls" do

  end

  describe "closed_pulls" do

  end

  describe "grouped_per_closed" do
    it "returns a hash" do
      expect(pulls.grouped_per_closed).to be_an_instance_of Hash
    end
  end

  describe "count_for_closed" do

  end

  describe "grouped_per_created_at" do
     it "returns a hash" do
      expect(pulls.grouped_per_created_at).to be_an_instance_of Hash
    end
  end

  describe "count_for_created_at" do


  end

end