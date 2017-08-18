require 'rails_helper'

RSpec.describe TwitterRecord, type: :model do
  before(:each) do
    @hash_1 = {
              :screen_name=>"test-guy",
              :description=>"/Web Developer and Does-Weller/",
              :followers_count=>98,
              :friends_count=>311,
              :tweets_count=>1075,
              :favorites_count=>396,
              :listed_count=>0,
              :recent_tweets=>0,
              :recent_mentions=>0,
                :recent_replies=>0
              }
    @record_1 = TwitterRecord.new(@hash_1)
  end
  describe "on initialization", :vcr do

    describe "fields set by the given hash" do
      describe "#screen_name" do
        it "is a string" do
          expect(@record.screen_name).to be_an_instance_of String
        end

        it "is readable" do
          expect(@record.screen_name).to eq @hash_1[:screen_name]
        end

        it "is writable" do
          @record.screen_name = "test"
          expect(@record.screen_name).to eq "test"
        end
      end

      describe "#description" do
        it "is a string" do
          expect(@record.description).to be_an_instance_of String
        end

        it "is readable" do
          expect(@record.description).to eq @hash_1[:description]
        end

        it "is writable" do
          @record.description = "test"
          expect(@record.description).to eq "test"
        end
      end

      describe "#followers_count" do
        it "is a Fixnum" do
          expect(@record.followers_count).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record.followers_count).to eq @hash_1[:followers_count]
        end

        it "is writable" do
          @record.followers_count = 0
          expect(@record.followers_count).to eq 0
        end
      end

      describe "#friends_count" do
        it "is a Fixnum" do
          expect(@record.friends_count).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record.friends_count).to eq @hash_1[:favorites_count]
        end

        it "is writable" do
          @record.friends_count = 0
          expect(@record.friends_count).to eq 0
        end
      end

      describe "#tweets_count" do
        it "is a Fixnum" do
          expect(@record.tweets_count).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record.tweets_count).to eq @hash_1[:tweets_count]
        end

        it "is writable" do
          @record.tweets_count = 0
          expect(@record.tweets_count).to eq 0
        end
      end

      describe "#favorites_count" do
        it "is a Fixnum" do
          expect(@record.favorites_count).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record.favorites_count).to eq @hash_1[:favorites_count]
        end

        it "is writable" do
          @record.favorites_count = 0
          expect(@record.favorites_count).to eq 0
        end
      end

      describe "#listed_count" do
        it "is a Fixnum" do
          expect(@record.listed_count).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record.listed_count).to eq @hash_1[:listed_count]
        end

        it "is writable" do
          @record.listed_count = 0
          expect(@record.listed_count).to eq 0
        end
      end

      describe "#recent_tweets" do
        it "is a Fixnum" do
          expect(@record.recent_tweets).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record.recent_tweets).to eq @hash_1[:recent_tweets]
        end

        it "is writable" do
          @record.recent_tweets = 0
          expect(@record.recent_tweets).to eq 0
        end
      end

      describe "#recent_mentions" do
        it "is a Fixnum" do
          expect(@record.recent_mentions).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record.recent_mentions).to eq @hash_1[:recent_mentions]
        end

        it "is writable" do
          @record.recent_mentions = 0
          expect(@record.recent_mentions).to eq 0
        end
      end

      describe "#recent_replies" do
        it "is a Fixnum" do
          expect(@record.recent_replies).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record.recent_replies).to eq @hash_1[:recent_replies]
        end

        it "is writable" do
          @record.recent_replies = 0
          expect(@record.recent_replies).to eq 0
        end
      end
    end


    describe "fields set on initialization by #inspect_old_data and total_differences" do   
      it "has a readable/writable recent_friends" do
        expect(@record.recent_friends).not_to raise_error NoMethodError
        @record.recent_friends = 1
        expect(@record.recent_friends).to be 1
      end

      it "has a readable/writable recent_followers" do
        expect(@record.recent_followers).not_to raise_error NoMethodError
        @record.recent_followers = 1
        expect(@record.recent_followers).to be 1
      end

      it "has a readable/writable recent_favorites" do
        expect(@record.recent_favorites).not_to raise_error NoMethodError
        @record.recent_favorites = 1
        expect(@record.recent_favorites).to be 1
      end

      it "has a readable/writable recent_lists" do
        expect(@record.recent_lists).not_to raise_error NoMethodError
        @record.recent_lists = 1
        expect(@record.recent_lists).to be 1
      end

      it "has a readable/writable total_differences" do
        expect(@record.total_differences).not_to raise_error NoMethodError
        @record.total_differences = 1
        expect(@record.total_differences).to be 1
      end
    end

    context "until record is saved " do
      it "has a readable created_at as nil" do
        expect(@record.created_at).to be nil
      end

      it "has a readable updated_at as nil" do
        expect(@record.updated_at).to be nil
      end
    end
  end

  describe "field assignment methods" do
    
    before(:each) do
    @record_1.save
    @hash_2 = {:screen_name=>"test-guy-2", :description=>"/Web Developer and Does-Weller/", :followers_count=>96, :friends_count=>314, :tweets_count=>1075, :favorites_count=>398, :listed_count=>2, :recent_tweets=>2, :recent_mentions=>1, :recent_replies=>1 }   
    @record_2 = TwitterRecord.new(@hash_2)

    @differences = [nil, "test-guy-2", nil, -2, 3, nil, 2, 2, 2, nil, 1, nil, nil, nil, nil, nil, nil, nil]
    
    end

    after(:each) do 
      TwitterRecord.find(@record_1.id).destroy
    end
    
    xdescribe "#assign_total_differences" do

    end

    describe "#compare_friends_count" do
      context "when there is a difference" do
        expect(adapter.compare_friends_count())
      end

      context "when there is no difference" do

      end
    end

    describe "#compare_followers_count" do
      context "when there is a difference" do

      end

      context "when there is no difference" do

      end
    end

    describe "#compare_favorites_count" do
      context "when there is a difference" do

      end

      context "when there is no difference" do

      end
    end

    describe "#compare_lists_count" do
      context "when there is a difference" do

      end

      context "when there is no difference" do

      end
    end
  end

  describe "difference calculations" do
    describe "#sub_differences" do

    end

    describe "#filter_differences" do

    end

    describe "#sum_up_differences" do

    end
  end
end
