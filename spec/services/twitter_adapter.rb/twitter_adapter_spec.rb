require 'rails_helper'

RSpec.describe TwitterAdapter do 
  let(:adapter) { TwitterAdapter.new }


  describe "#retrieve_profile", :vcr do
    it "returns a Twitter::User object" do
      expect(adapter.retrieve_profile).to be_an_instance_of Twitter::User
    end

    it "should return the twitter user from the ENV" do
      expect(adapter.retrieve_profile.username).to eq twitter_user
    end

  end


  describe "#aggregate_data_record", :vcr do
    it "returns a hash of all api-important data" do
      expect(adapter.aggregate_data_record).to be_an_instance_of Hash
    end
  end

  describe "#counts_by_date", :vcr do
    before do
      allow_any_instance_of(TwitterAdapter)
        .to_recieve(:counts_by_date)
        .and_return({"2017-12-12" => {tweet_count: 1}})
    end

    it "returns a hash" do
      expect(adapter.counts_by_date).to be_an_instance_of Hash
    end

    it "has valid date keys" do
      expect(Date.parse(adapter.counts_by_date.keys.first)).not_to raise_error
    end
  end

  describe "#recent_tweets", :vcr do
    let(:collection) { adapter.recent_tweets }
    it "returns a tweet collection obj" do
      expect(collection).to be_an_instance_of TwitterAdapter::TweetCollection
    end
  end

  describe "#recent_replies", :vcr do
    let(:collection) { adapter.recent_replies 

    it "returns a tweet collection obj" do
      expect(collection).to be_an_instance_of TwitterAdapter::TweetCollection
    end
  end

  describe "#recent_mentions", :vcr do
    let(:collection) { adapter.recent_mentions 

    it "returns a tweet collection obj" do
      expect(collection).to be_an_instance_of TwitterAdapter::TweetCollection
    end
  end

  describe "#formatted_profile", :vcr do
    it "returns a hash" do
      expect(adapter.formatted_profile).to be_an_instance_of Hash
    end
  end  
end