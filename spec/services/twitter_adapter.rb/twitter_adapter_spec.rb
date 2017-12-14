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
        expect(adapter.user).not_to raise_error
      end
    end

    describe "#two_weeks_ago" do
      it "exists" do
        expect(adapter.user).not_to raise_error
      end
    end
  end

  describe "#retrieve_profile", :vcr do

  end

  describe "#aggregate_data_record", :vcr do

  end

  describe "#counts_by_date", :vcr do

  end

  describe "#recent_tweets", :vcr do

  end

  describe "#recent_replies", :vcr do

  end

  describe "#recent_mentions", :vcr do

  end

  describe "#formatted_profile", :vcr do

  end  
end