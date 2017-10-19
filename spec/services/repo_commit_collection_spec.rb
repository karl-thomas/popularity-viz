require 'rails_helper'

RSpec.describe Repo::CommitCollection do
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
end