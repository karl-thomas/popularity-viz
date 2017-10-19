require 'rails_helper'

RSpec.describe Repo, :vcr do
  let(:adapter) {GithubAdapter.new}
  let(:sawyer_resource) { adapter.client.repos(github_login).first}
  let(:repo) { Repo.new(sawyer_resource) }
  describe "on initialization", :vcr do

    it "has a root, the Sawer::Resource" do
      expect(repo.root).to be_an_instance_of Sawyer::Resource
    end

    describe "id" do 
      it "is assigned a id from the resource" do
        expect(repo.id).to eq sawyer_resource.id
      end

      it "is an integer" do
        expect(repo.id).to be_an_instance_of Integer
      end
    end

    describe "full_name" do 
      it "is assigned a full_name from the resource" do
        expect(repo.full_name).to eq sawyer_resource.full_name
      end

      it "is an String" do
        expect(repo.full_name).to be_an_instance_of String
      end
    end

    describe "watchers_count" do 
      it "is assigned a watchers_count from the resource" do
        expect(repo.watchers_count).to eq sawyer_resource.watchers_count
      end

      it "is an integer" do
        expect(repo.watchers_count).to be_an_instance_of Integer
      end
    end 

    describe "updated_at" do 
      it "is assigned a updated_at from the resource" do
        expect(repo.updated_at).to eq sawyer_resource.updated_at
      end

      it "is a Time Object" do
        expect(repo.updated_at).to be_an_instance_of Time
      end
    end 

    describe "pushed_at" do 
      it "is assigned a pushed_at from the resource" do
        expect(repo.pushed_at).to eq sawyer_resource.pushed_at
      end

      it "is a Time Object" do
        expect(repo.pushed_at).to be_an_instance_of Time
      end
    end

    describe "traffic data" do
      it "is an instance of Repo::TrafficData" do
        expect(repo.traffic_data).to be_an_instance_of Repo::TrafficData
      end

      it "is assigned the repo to keep track of" do
        expect(repo.traffic_data.repo.id).to eq repo.id
      end
    end
  end 

  describe "pull request behaviour" do
    describe "#recent_pull_requests" do
      it "returns an PullRequests Obj" do
        expect(repo.recent_pull_requests).to be_an_instance_of Repo::PullRequests
      end

      context "when there are recent_pull_requests" do
        it "pull requests will be within two weeks old" do
          pull_requests = repo.recent_pull_requests
          if pull_requests.empty?
            created_at = pull_requests.first[:created_at]
            expect(created_at).to be < two_weeks_ago
          end
        end
      end
    end
  end

  describe "#collaborators", :vcr do
    it "returns an array of strings" do
      expect(repo.collaborators.first).to be_an_instance_of String
    end

    it "the strings represent someone who is collaborating on that repo" do
      collaborator = repo.collaborators.first
      repos = adapter.client.repos(collaborator, affiliation: 'collaborator').pluck(:full_name)
      expect(repos).to include repo.full_name
    end
  end

  describe "#recent?" do
    let(:repo) { adapter.owned_repos.repos.find { |r| r.recent? } }
    it "determines of the repo has been updated in the past 2 weeks" do
      expect(repo.pushed_at).to be > two_weeks_ago
    end

    it "returns a boolean value" do
      expect(repo.recent?).to be(true).or(false)
    end
  end

  describe "#recent_commits" do
    it "makes a request to the github api for recent commits" do
      repo.recent_commits
      request_uri = "/repos/#{repo.full_name}/commits?author=#{github_login}&#{auth_client_params}&per_page=100" + since
      assert_requested :get, github_url(request_uri)
    end

    it "returns a Commits obj" do
      expect(repo.recent_commits.first).to be_an_instance_of Repo::Commits
    end

    it "returns commits within the past two weeks" do
      commit = repo.recent_commits.first
      expect(commit[:date]).to be > two_weeks_ago
    end
  end

  describe "#all_commit_comments" do
    let(:comments) { repo.all_commit_comments }
    it "makes a request to the github api for all commits" do
      repo.all_commit_comments
      request_uri = "/repos/#{repo.full_name}/comments?#{auth_client_params}&per_page=100"
      assert_requested :get, github_url(request_uri)
    end

    it "returns an array of sawyer_resources" do
      expect(comments).to be_an_instance_of Array
      if !comments.empty?
        expect(comments.first).to be_an_instance_of Sawyer::Resource
      end
    end
  end

  describe "#recent_commit_comments" do
    let(:comments) { repo.recent_commit_comments }
    context "when there are recent comments" do
      it "returns an array of sawyer_resources" do
        if !comments.empty?
          expect(comments.first).to be_an_instance_of Sawyer::Resource
        end
      end
    end
    context "when there are no recent comments" do
      it "returns an array" do
        expect(comments).to be_an_instance_of Array
      end
    end
  end

  describe "#deployments" do
    let(:deployments) { repo.deployments }
    it "makes a request to the github api for all deployments" do
      repo.deployments
      request_uri = "/repos/#{repo.full_name}/deployments?#{auth_client_params}"
      assert_requested :get, github_url(request_uri)
    end

    it "returns an array of sawyer_resources" do
      expect(deployments).to be_an_instance_of Array
      if !deployments.empty?
        expect(deployments.first).to be_an_instance_of Sawyer::Resource
      end
    end
  end

  describe "#recent_deployments" do
    let(:deployments) { repo.recent_deployments }
      context "when there are recent deployments" do
        it "returns an array of sawyer_resources" do
          if !deployments.empty?
            expect(deployments.first).to be_an_instance_of Sawyer::Resource
          end
        end
      end
    context "when there are no recent deployments" do
      it "returns an empty array" do
        allow(repo).to receive(:deployments) { [] }
        expect(deployments.empty?).to eq true
      end
    end
  end

  describe "#languages" do
    let(:languages) { repo.languages }
    it "makes a request to the github api for all languages" do
      repo.languages
      request_uri = "/repos/#{repo.full_name}/languages?#{auth_client_params}&per_page=100"
      assert_requested :get, github_url(request_uri)
    end

    it "returns a Sawyer::Resource" do
      expect(languages).to be_an_instance_of Sawyer::Resource
    end

    it "returns a hash with values that represent the bytes of a language" do
      # sawyer::resources does not have a .values even tho it is similar to a hash. 
      expect(languages.to_a[0][1]).to be_an_instance_of Integer
    end
  end

  describe "#top_language" do
    before do
      allow(repo).to receive(:languages) { {'Ruby' => 0, "Java" => 400} }
    end
    it "returns an array " do
      expect(repo.top_language).to be_an_instance_of Array
    end

    it "returns the language as a string in its first language" do
      expect(repo.top_language.first).to eq 'Java'
    end

    it "returns the bytes as the second index of its array " do
      expect(repo.top_language[1]).to eq 400
    end
  end

  describe "#stargazers" do
    let(:stargazers) { repo.stargazers }
    it "makes a request to the github api for all stargazers" do
      repo.stargazers
      request_uri = "/repos/#{repo.full_name}/stargazers?per_page=100"
      assert_requested :get, github_url(request_uri)
    end

    it "returns an array of strings" do
      expect(stargazers).to be_an_instance_of Array
      if !stargazers.blank?
        expect(stargazers.first).to be_an_instance_of String
      end
    end
  end

  describe "#dependent_repo_data" do
    let(:data) { repo.dependent_repo_data }
    it "returns a hash containing itself and information about the thing" do
      expect(data).to be_an_instance_of Hash
    end
  end
end

