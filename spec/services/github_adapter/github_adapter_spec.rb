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
    # it "calls the github api with a request for a profile", :vcr do
    #   adapter.profile
    #   assert_requested :get, github_url("/users/#{github_login}")
    # end

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

  describe "#find_repo", :vcr do
    before do
      @repo_id = adapter.owned_repos.first.id
      @repo = adapter.find_repo(@repo_id)
    end
    it "returns a repo object" do
      expect(@repo).to be_an_instance_of Repo
    end

    it "finds a repo with the same id as the arguement" do
      expect(@repo.id).to eq @repo_id
    end
  end


  describe "#owned_repos" do
    before(:each) do

      @owned_repos = adapter.owned_repos
    end
    # it "makes a call to the gihub api for owned repos", :vcr do
    #   affiliation = "affiliation=owner"
    #   request_uri = "/users/#{github_login}/repos?#{affiliation}&#{auth_client_params}&per_page=100"
    #   assert_requested :get, github_url(request_uri)
    # end

    it "returns a RepoCollection object", :vcr do
      expect(@owned_repos).to be_an_instance_of RepoCollection
    end

    it "returns an array of Repo objs", :vcr do
      expect(@owned_repos.first).to be_an_instance_of Repo
    end

    it "returns an array of repo objs owned by the user", :vcr do
      expect(@owned_repos.first.owner[:login]).to eq github_login
    end
  end

  describe "#collaborated_repos" do
    before(:each) do
      @collaborated_repos = adapter.collaborated_repos
    end

    # it "makes a call to the gihub api for collaborated on repos", :vcr do
    #   affiliation = "affiliation=collaborator"
    #   request_uri = "/users/#{github_login}/repos?#{affiliation}&#{auth_client_params}&per_page=100"
    #   assert_requested :get, github_url(request_uri)    
    # end

    it "returns an RepoCollection object", :vcr do
      expect(@collaborated_repos).to be_an_instance_of RepoCollection
    end

    it "returns an array of Repo objs", :vcr do
      expect(@collaborated_repos.first).to be_an_instance_of Repo
    end

    it "returns and array of repo objs collaborated on by the user", :vcr do     
      expect(@collaborated_repos.first.collaborators).to include github_login
    end
  end

  describe "#starred_repos" do
    before(:each) do
      @starred_repos = adapter.starred_repos
    end

    # it "makes a request to the github api for starred repos", :vcr do
    #   request_uri = "/users/#{github_login}/starred?#{auth_client_params}&per_page=100"
    #   assert_requested :get, github_url(request_uri) 
    # end

    it "returns an RepoCollection object", :vcr do
      expect(@starred_repos).to be_an_instance_of RepoCollection
    end

    it "return an array of repo objs", :vcr do
      expect(@starred_repos.first).to be_an_instance_of Repo
    end

    it "return an array of repos starred by the user", :vcr do
      expect(@starred_repos.first.stargazers).to include github_login
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


  describe "gist methods" do 
    let(:since) { "&since=#{two_weeks_ago}"}
    describe "#recent_gists", :vcr do
      # it "makes a request to the github api for recent gists" do
      #   adapter.recent_gists
      #   request_uri = "/users/#{github_login}/gists?#{auth_client_params}&per_page=100" + since
      #   assert_requested :get, github_url(request_uri)
      # end
      
      describe "return values" do
        before do
          adapter.personal_client
          new_gist = {
            :description => "A gist from Octokit",
            :public      => true,
            :files       => {
              "zen.text" => { :content => "Keep it logically awesome." }
            }
          }

          @gist = adapter.client.create_gist(new_gist)
          @gist_comment = adapter.client.create_gist_comment(5421307, ":metal:")

          @gists = adapter.recent_gists
        end

        after do
          adapter.personal_client
          adapter.client.delete_gist @gist.id
        end

        it "returns an array" do
          expect(@gists).to be_an_instance_of Array
        end
      end
    end

    describe "#recent_starred_gists", :vcr do
      # it "makes a request to the github api for recent gists" do
      #   adapter.recent_gists
      #   request_uri = "/users/#{github_login}/gists?#{auth_client_params}&per_page=100" + since
      #   assert_requested :get, github_url(request_uri)
      # end
      
      describe "return values", :vcr do
        before do
          adapter.personal_client
          new_gist = {
            :description => "A gist from Octokit",
            :public      => true,
            :files       => {
              "zen.text" => { :content => "Keep it logically awesome." }
            }
          }

          @gist = adapter.client.create_gist(new_gist)
          adapter.client.star_gist(@gist.id)
          @gists = adapter.recent_starred_gists
        end

        after do
          adapter.personal_client
          adapter.client.delete_gist @gist.id
        end

        it "returns an array" do
          expect(@gists).to be_an_instance_of Array
        end
      end
    end
  end
end

