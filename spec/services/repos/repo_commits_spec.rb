require 'rails_helper'

RSpec.describe Repo::Commits do
  let(:collection) { GithubAdapter.new.owned_repos.first.recent_commits}
  describe "on initialization", :vcr do
    describe "#commits" do
      it "is a readable array" do
        expect(collection.commits).to be_an_instance_of Array
      end
    end
  end

  describe "#count", :vcr do
    it "returns the count of commits", :vcr do
      expect(collection.count).to eq collection.commits.count
    end
  end

  describe "#first", :vcr do
    it "returns the first element of commits", :vcr do
      expect(collection.first).to eq collection.commits[0]
    end
  end

  describe "#messages", :vcr do
    it "returns an array", :vcr do
      expect(collection.messages).to be_an_instance_of Array
    end

    it "returns an array of String", :vcr do
      expect(collection.messages.first).to be_an_instance_of String
    end
  end

  describe "group_per_day", :vcr do
    it "returns a hash of dates of commits grouped", :vcr do
      expect(collection.group_per_day).to be_an_instance_of Hash
    end
  end

  describe "count_per_day", :vcr do
    it "returns a hash of dates ", :vcr do
      expect(collection.count_per_day).to be_an_instance_of Hash
    end

    it "has a value with a count of commits", :vcr do
      expect(collection.count_per_day.values.first[:commits]).to be_an_instance_of Integer
    end
  end

  describe "#recent_commit_dates" do 
    it "returns a hash of commits grouped by dates" do
      commits = collection.recent_commit_dates
      date = commits.keys.first
      expect(Date.parse(date)).to be_truthy
    end

    it "returns a hash of a date pointing to an array" do
      expect(commits.values.first).to be_an_instance_of Array
    end
  end

  describe "#recent_commit_time_ranges" do
    #  the commented out tests need to be stubbed. 
    it "returns a nested array" do
      expect(collection.recent_commit_time_ranges).to be_an_instance_of Array
      # expect(repo.recent_commit_time_ranges.first).to be_an_instance_of Array
    end

    # it "groups times of the same date in an array together" do
    #   times = repo.recent_commit_time_ranges
    #   expect(times[0][0].strftime('%D')).to eq times[0][1].strftime('%D')
    # end
  end

  #   describe "#all_commit_comments" do
  #   let(:comments) { repo.all_commit_comments }
  #   it "makes a request to the github api for all commits" do
  #     repo.all_commit_comments
  #     request_uri = "/repos/#{repo.full_name}/comments?#{auth_client_params}&per_page=100"
  #     assert_requested :get, github_url(request_uri)
  #   end

  #   it "returns an array of sawyer_resources" do
  #     expect(comments).to be_an_instance_of Array
  #     if !comments.empty?
  #       expect(comments.first).to be_an_instance_of Sawyer::Resource
  #     end
  #   end
  # end

  # describe "#recent_commit_comments" do
  #   let(:comments) { repo.recent_commit_comments }
  #   context "when there are recent comments" do
  #     it "returns an array of sawyer_resources" do
  #       if !comments.empty?
  #         expect(comments.first).to be_an_instance_of Sawyer::Resource
  #       end
  #     end
  #   end
  #   context "when there are no recent comments" do
  #     it "returns an array" do
  #       expect(comments).to be_an_instance_of Array
  #     end
  #   end
  # end
end