require 'rails_helper'

RSpec.describe Repo, :vcr do
  let(:adapter) {GithubAdapter.new}
  let(:sawyer_resource) { adapter.client.repos(github_login).first}
  let(:repo) { Repo.new(sawyer_resource) }
  describe "on initialization", :vcr do

    #  @root = sawyer_resource
    # @owner = root.owner
    # @id = root.id || nil
    # @full_name = root.full_name || nil
    # @watchers_count = root.watchers_count || nil
    # @updated_at = root.updated_at
    # @pushed_at = root.pushed_at
    # @two_weeks_ago = 2.weeks.ago.strftime("%Y-%m-%d")
    # @traffic_data = TrafficData.new( self, application_client, personal_client)
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
  end 

  describe "pull request behaviour" do
    describe "#recent_pull_requests" do
      it "returns an array" do
        expect(repo.recent_pull_requests).to be_an_instance_of Array
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

  describe "#collaborators" do

  end

  describe "#recent?" do

  end

  describe "#recent_commits" do

  end

  describe "#recent_commit_dates" do

  end

  describe "#recent_commit_time_ranges" do

  end

  describe "#all_commit_comments" do

  end

  describe "#recent_commit_comments" do

  end

  describe "#deployments" do

  end

  describe "#recent_deployments" do

  end

  describe "#branches" do

  end

  describe "#languages" do

  end

  describe "#top_language" do

  end

  describe "#stargazers" do

  end

  describe "#dependent_repo_data" do

  end
end
# --------- TO BE MOVED TO REPO(COLLECTION) CLASS SPECS --------
    # describe "#convert_to_repos" do
  #   before(:each) do
  #     repos = adapter.client.repos(github_login)
  #     @converted_repos = adapter.convert_to_repos(repos)
  #   end

  #   it "returns an array", :vcr do
  #     expect(@converted_repos).to be_an_instance_of Array
  #   end

  #   it "converts an array of sawyers resource to an array of repo objects", :vcr do
  #     expect(@converted_repos.first).to be_an_instance_of Repo
  #   end
  # end
  # describe "#reduce_repo_data" do
  #   it "returns a hash of reduced information from collect_repo_data", :vcr do
  #     result = adapter.reduced_repo_data
  #     expect(result).to be_an_instance_of Hash
  #   end

  #   it "returns a hash with the default value of 0", :vcr do
  #     result = adapter.reduced_repo_data
  #     expect(result[:repo_id]).to eq 0
  #   end

  #   it "adds :most_recent_project", :vcr do
  #     result = adapter.reduced_repo_data
  #     expect(result[:most_recent_project]).not_to be 0
  #   end

  #   it "removes :repo", :vcr do
  #     result = adapter.reduced_repo_data
  #     expect(result[:repo]).to be 0
  #   end

  #   it "has a concise :most_used_lang", :vcr do
  #     result = adapter.reduced_repo_data
  #     expect(result[:most_used_lang]).to be_an_instance_of Symbol
  #   end
  # end

  # describe "#collect_traffic_data" do
  #   it "returns an array of hashes ", :vcr do 
  #     result = adapter.collect_traffic_data
  #     expect(result).to be_an_instance_of Array
  #     expect(result.first).to be_an_instance_of Hash
  #   end

  #   it "the hash it returns matches a certain structure", :vcr do
  #     result = adapter.collect_traffic_data
  #     expect(result.first).to match(
  #      :repo_id=> an_instance_of(Fixnum),
  #      :recent_views=> an_instance_of(Fixnum),
  #      :recent_clones=> an_instance_of(Fixnum),
  #      :unique_views=> an_instance_of(Fixnum),
  #      :recent_stargazers=> an_instance_of(Fixnum),
  #      :watchers=> an_instance_of(Fixnum)
  #     )
  #   end
  # end

  # describe "#reduced_traffic_data" do 
  #   it "squashes the collected traffic data of all owned repos into a single hash", :vcr do
  #     result = adapter.reduced_traffic_data
  #     expect(result).to be_an_instance_of Hash
  #   end

  #   it "returns a hach with the default value of 0", :vcr do
  #     result = adapter.reduced_traffic_data
  #     expect(result[:repo_id]).to eq 0
  #   end

  #   it "does not include :repo_id", :vcr do
  #     result = adapter.reduced_traffic_data
  #     expect(result[:repo_id]).to eq 0
  #   end

  #   it "chooses the most trafficy repo", :vcr do
  #     result = adapter.reduced_traffic_data
  #     expect(result[:hottest_repo]).not_to be 0
  #   end
  # end
  # describe "#collect_repo_data" do
  #   it "returns an array of hashes", :vcr do
  #     expect(adapter.collect_repo_data).to be_an_instance_of Array
  #     expect(adapter.collect_repo_data.first).to be_an_instance_of Hash
  #   end

  #   it "creates hashes of a certain structure", :vcr do
  #     expect(adapter.collect_repo_data.first).to  match(
  #         :repo=> an_instance_of(Repo),
  #         :recent_commits=> an_instance_of(Fixnum),
  #         :recent_comments=> an_instance_of(Fixnum),
  #         :recent_deployments=> an_instance_of(Fixnum),
  #         :branches=> an_instance_of(Fixnum),
  #         :most_used_lang=> an_instance_of(Array)
  #       )
  #   end
  # end
  # describe "#recent_updated_repos" do
  #   before(:each) do
  #     repos = adapter.owned_repos
  #     @filtered_repos = adapter.recent_updated_repos(repos)
  #   end

  #   it "returns an array", :vcr do
  #     expect(@filtered_repos).to be_an_instance_of Array
  #   end

  #   it "returns an array of repo objects", :vcr do
  #     expect(@filtered_repos.first). to be_an_instance_of Repo
  #   end

  #   it "returns an array of repo objects pushed at more recently than two weeks ago", :vcr do
  #     expect(@filtered_repos.first.pushed_at).to be >= two_weeks_ago
  #   end
  # end
