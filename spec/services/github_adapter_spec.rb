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

  describe "#personal_client" do
    it "assigns a basic auth ocktokit client" do
      adapter.personal_client
      expect(adapter.client.login).to eq github_login
    end

    it "unassigns the application ocktokit client" do
      adapter.personal_client
      expect(adapter.client.client_id).to eq nil
    end
  end

  describe "#application_client" do
    it "assigns a application ocktokit client" do
      adapter.application_client
      expect(adapter.client.client_id).to eq test_github_client_id
    end

    it "unassigns the application ocktokit client" do
      adapter.application_client
      expect(adapter.client.login).to eq nil
    end
  end

  describe "#profile_data" do
    it "returns a hash of data", :vcr do
      expect(adapter.profile_data).to match(
       :username=> a_string_matching(github_login),
       :repos=> an_instance_of(Fixnum),
       :gists=> an_instance_of(Fixnum),
       :followers=> an_instance_of(Fixnum),
       :following=> an_instance_of(Fixnum),
       :starred_repos=> an_instance_of(Fixnum),
       :recent_projects=> an_instance_of(Fixnum),
       :recent_gists=> an_instance_of(Fixnum),
       :recently_starred_gists=> an_instance_of(Fixnum)
      )
    end
  end

  describe "#total_gists" do
    it "returns the sum of all gists", :vcr do
      expect(adapter.total_gists).to be_an_instance_of Fixnum

    end
  end

  describe "#total_repos" do
    it "returns the sum of all repos", :vcr do
      expect(adapter.total_repos).to be_an_instance_of Fixnum

    end
  end

  describe "#owned_repos" do
    it "makes a call to the gihub api for owned repos", :vcr do
      adapter.owned_repos
      affiliation = "affiliation=owner"
      client_id = "client_id=#{test_github_client_id}"
      client_secret = "client_secret=#{test_github_client_secret}"
      request_uri = "/users/#{github_login}/repos?#{affiliation}&#{client_id}&#{client_secret}&per_page=100"
      assert_requested :get, github_url(request_uri)
    end

    it "returns an array of repo objs owned by the user", :vcr do
      owned_repos = adapter.owned_repos
      expect(owned_repos).to be_an_instance_of Array
      expect(owned_repos.first).to be_an_instance_of Repo
      expect(owned_repos.first.owner[:login]).to eq github_login
    end
  end

  describe "#collaborated_repos" do
    it "makes a call to the gihub api for collaborated on repos", :vcr do
      adapter.collaborated_repos
      affiliation = "affiliation=collaborator"
      client_id = "client_id=#{test_github_client_id}"
      client_secret = "client_secret=#{test_github_client_secret}"
      request_uri = "/users/#{github_login}/repos?#{affiliation}&#{client_id}&#{client_secret}&per_page=100"
      assert_requested :get, github_url(request_uri)    
    end

    it "returns and array of repo objs collaborated on by the user", :vcr do
      collaborated_repos = adapter.collaborated_repos
      expect(collaborated_repos).to be_an_instance_of Array
      expect(collaborated_repos.first).to be_an_instance_of Repo
      expect(collaborated_repos.first.collaborators).to include github_login
    end
  end

  xdescribe "#organizations_repos" do
    it "returns and array of repo objs in the same organizations as the user.", :vcr do
      organizations_repos = adapter.organizations_repos
      expect(organizations_repos).to be_an_instance_of Array
      expect(organizations_repos.first).to be_an_instance_of Repo
      expect(organizations_repos.first.organization).to include github_organization
    end
  end

  describe "#convert_to_repos" do
    it "converts an array of sawyers resource to an array of repo objects", :vcr do
      repos = adapter.client.repos(github_login)
      converted_repos = adapter.convert_to_repos(repos)
      expect(converted_repos).to be_an_instance_of Array
      expect(converted_repos.first).to be_an_instance_of Repo
    end
  end

  describe "#recent_updated_repos" do
    before(:each) do
      repos = adapter.owned_repos
      @filtered_repos = adapter.recent_updated_repos(repos)
    end

    it "returns an array", :vcr do
      expect(@filtered_repos).to be_an_instance_of Array
    end

    it "returns an array of repo objects", :vcr do
      expect(@filtered_repos.first). to be_an_instance_of Repo
    end

    it "returns an array of repo objects pushed at more recently than two weeks ago", :vcr do
      expect(@filtered_repos.first.pushed_at).to be >= two_weeks_ago
    end
  end

  describe "#starred_repos" do
    before(:each) do
      @starred_repos = adapter.starred_repos
    end

    it "makes a request to the github api for starred repos", :vcr do
      client_id = "client_id=#{test_github_client_id}"
      client_secret = "client_secret=#{test_github_client_secret}"
      request_uri = "/users/#{github_login}/starred?#{client_id}&#{client_secret}&per_page=100"
      assert_requested :get, github_url(request_uri) 
    end

    it "returns an array", :vcr do
      expect(@starred_repos).to be_an_instance_of Array
    end

    it "return an array of repo objs", :vcr do
      expect(@starred_repos.first).to be_an_instance_of Repo
    end

    it "return an array of repos starred by the user", :vcr do
      expect(@starred_repos.first.stargazers).to include github_login
    end
  end
end
