require 'rails_helper'

Rspec.describe Repo do
  describe "on initialization" do
    
  end
  describe "#convert_to_repos" do
    before(:each) do
      repos = adapter.client.repos(github_login)
      @converted_repos = adapter.convert_to_repos(repos)
    end

    it "returns an array", :vcr do
      expect(@converted_repos).to be_an_instance_of Array
    end

    it "converts an array of sawyers resource to an array of repo objects", :vcr do
      expect(@converted_repos.first).to be_an_instance_of Repo
    end
  end
end
# --------- TO BE MOVED TO REPO(COLLECTION) CLASS SPECS --------
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
