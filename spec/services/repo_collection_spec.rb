require 'rails_helper'


RSpec.describe RepoCollection, :vcr do
  let(:repo_data) {GithubAdapter.new.owned_repos.repos}
  let(:collection) {RepoCollection.new(repo_data)}
  describe "on initialization" do
    it "is assigned an array of repos" do
      expect(collection.repos.first).to be_an_instance_of Repo
    end

    it "raises an error if the arguments is an empty array" do
      expect{ RepoCollection.new([]) }.to raise_error RepoCollection::NoReposError
    end
  end

  describe "#assign_repos" do
    context "when passed repo objs in an array" do
      it "returns an unaltered array" do
        assignments = collection.assign_repos(repo_data)
        expect(assignments).to eq repo_data
      end
    end

    context "when passed sawyer objs in an array" do
      it "returns an array of repo obj" do
        github_data = GithubAdapter.new.client.repos(github_login, affiliation: 'owner')
        assignments = collection.assign_repos(github_data)
        expect(assignments.first).to be_an_instance_of Repo
      end
    end

    context "when the array passed in does not contain sawyer objs or repo objs" do
      it "throws an error" do
        expect{ collection.assign_repos([0,0,0]) }.to raise_error RepoCollection::NoReposError
      end
    end
  end

  describe "#convert_to_repos" do
    it "converts an array of sawyer::resource to repo objs" do
      github_data = GithubAdapter.new.client.repos(github_login, affiliation: 'owner')
      expect(collection.convert_to_repos(github_data).first).to be_an_instance_of Repo
    end

    it "returns an array" do
      github_data = GithubAdapter.new.client.repos(github_login, affiliation: 'owner')
      expect(collection.convert_to_repos(github_data)).to be_an_instance_of Array
    end
  end

  describe "#count" do
    it "returns an integer" do
      expect(collection.count).to be_an_instance_of Integer
    end

    it "returns the count of repos in it's state" do
      expect(collection.count).to eq collection.repos.count
    end

    it "has an alias called #length" do
      expect(collection.count).to eq collection.length
    end
  end

  describe "#[]" do
    it "returns a repo obj at a certain index" do
      expect(collection[0]).to be_an_instance_of Repo
    end

    it "returns a repo for its state" do
      expect(collection.repos).to include collection[0]
    end
  end

  describe "#first" do
    it "returns an instance of repo" do
      expect(collection.first).to be_an_instance_of Repo
    end

    it "returns the first repo from its state" do
      expect(collection.first).to eq collection.repos[0]
    end
  end

  describe "#recent_repos" do
    it "returns an instance of Array " do
      expect(collection.recent_repos).to be_an_instance_of Array
    end

    it "only returns repos that have been updated recently" do
      expect(collection.recent_repos.first.recent?).to eq true
    end   
  end

  describe "#recent_repo_data" do
    let(:data) {collection.recent_repo_data}
    it "returns an array" do
      expect(data).to be_an_instance_of Array
    end

    it 'returns an array of dependent_repo_data from the Repo class' do
      expect(data[0]).to eq collection.first.dependent_repo_data
    end
  end

  describe "#most_used_language" do
    it "returns an array of the most used language, and it's bytes" do
      allow_any_instance_of(Repo).to receive(:dependent_repo_data).and_return({:most_used_lang => [:Ruby, 0]})
      expect(collection.most_used_language).to eq [:Ruby, 0]
    end
  end

  describe "#most_recent_project" do
    it "returns the most recently worked on repo" do
      expect(collection.most_recent_project).to be_an_instance_of Repo
    end
  end

  describe "#reduced_repo_data" do
    it "returns a hash of reduced #recent_repo_data" do
      expect(collection.reduced_repo_data).to be_an_instance_of Hash
    end
  end

  describe "#collect_traffic_data" do
    let(:data) {collection.collect_traffic_data}
    it "returns an array" do
      expect(data).to be_an_instance_of Array
    end

    it 'returns an array of dependent_repo_data from the Repo class' do
      expect(data[0]).to eq collection.first.traffic_data.to_h
    end
  end

  describe "#most_viewed_repo" do
    it "returns a hash of the repo with the greatest amount of views" do
      allow_any_instance_of(Repo::TrafficData).to receive(:sum_of_interactions).and_return(1)
      repo = collection.most_viewed_repo
      expect(repo).to eq collection.first.traffic_data.to_h
    end 
  end

  describe "#reduced_traffic_data" do
    it "returns a hash of reduced traffice data of all repos" do
      expect(collection.reduced_traffic_data).to be_an_instance_of Hash
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
  
end