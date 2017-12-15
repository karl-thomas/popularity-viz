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

      it "returns a string of a date"
        expect(Date.parse(adapter.two_weeks_ago)).not_to raise_error
      end
    end
  end

  describe "#retrieve_profile", :vcr do
    it "returns a Twitter::User object" do
      expect(adapter.retrieve_profile).to be_an_instance_of Twitter::User
    end

    it "should return the twitter user from the ENV" do

    end
    
    it "makes a request to the twitter api" do

    end

  end


  describe "#aggregate_data_record", :vcr do

  end

  describe "#counts_by_date", :vcr do

  end

  describe "#recent_tweets", :vcr do
    it "makes a request to the twitter api" do
      
    end

  end

  describe "#recent_replies", :vcr do
    it "makes a request to the twitter api" do
      
    end

  end

  describe "#recent_mentions", :vcr do
    it "makes a request to the twitter api" do
      
    end

  end

  describe "#formatted_profile", :vcr do

  end  
end