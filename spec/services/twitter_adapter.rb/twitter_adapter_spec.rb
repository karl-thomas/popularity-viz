require 'rails_helper'

RSpec.describe TwitterAdapter do 
  let(:adapter) { TwitterAdapter.new }
  describe "on initialization", :vcr do
    describe "#user" do
      it "exists" do
        expect(adapter.user).not_to raise_error
      end

      it "is the env key for twitter users" do
        expect(adapter.user).to eq twitter_user
      end
    end

    describe "#client" do
      it "exists" do
        expect(adapter.client).not_to raise_error
      end

      it "returns an instance of Twitter::REST::Client" do
        expect(adapter.client).to be_an_instance_of Twitter::REST::Client
      end
    end

    describe "#two_weeks_ago" do
      it "exists" do
        expect(adapter.two_weeks_ago).not_to raise_error
      end

      it "returns a string of a date" do
        expect(Date.parse(adapter.two_weeks_ago)).not_to raise_error
      end
    end
  end

  describe "#retrieve_profile", :vcr do
    it "returns a Twitter::User object" do
      expect(adapter.retrieve_profile).to be_an_instance_of Twitter::User
    end

    it "should return the twitter user from the ENV" do
      expect(adapter.retrieve_profile.username).to eq twitter_user
    end
    
    it "makes a request to the twitter api" do
      adapter.retrieve_profile
      assert_requested :get, ''
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

    it "makes a request to the twitter api" do
      assert_requested :get, ''
    end
  end

  describe "#recent_replies", :vcr do
    let(:collection) { adapter.recent_replies }
    it "makes a request to the twitter api" do
      assert_requested :get, ''
    end

    it "returns a tweet collection obj" do
      expect(collection).to be_an_instance_of TwitterAdapter::TweetCollection
    end
  end

  describe "#recent_mentions", :vcr do
    let(:collection) { adapter.recent_mentions }
    it "makes a request to the twitter api" do
      assert_requested :get, ''
    end

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