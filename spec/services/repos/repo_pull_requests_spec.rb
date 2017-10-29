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
   oauth_client
  describe "comments" do

  end
  describe "comments_by_date" do

  end
  describe "count_of_comments_by_date" do

  end
  describe "create_pulls(pulls)" do

  end
  describe "date_grouped_data" do

  end
  describe "recent_pulls" do

  end
  describe "closed_pulls" do

  end
  describe "grouped_per_closed" do

  end
  describe "count_for_closed" do

  end
  describe "grouped_per_created_at" do

  end
  describe "count_for_created_at" do

  end

end