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

  describe " -- on initialization -- ", :vcr do

    describe " - fields set by the given hash" do
      describe "#screen_name" do
        it "is a string" do
          expect(@record_1.screen_name).to be_an_instance_of String
        end

        it "is readable" do
          expect(@record_1.screen_name).to eq @hash_1[:screen_name]
        end

        it "is writable" do
          @record_1.screen_name = "test"
          expect(@record_1.screen_name).to eq "test"
        end
      end

      describe "#description" do
        it "is a string" do
          expect(@record_1.description).to be_an_instance_of String
        end

        it "is readable" do
          expect(@record_1.description).to eq @hash_1[:description]
        end

        it "is writable" do
          @record_1.description = "test"
          expect(@record_1.description).to eq "test"
        end
      end

      describe "#followers_count" do
        it "is a Fixnum" do
          expect(@record_1.followers_count).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record_1.followers_count).to eq @hash_1[:followers_count]
        end

        it "is writable" do
          @record_1.followers_count = 0
          expect(@record_1.followers_count).to eq 0
        end
      end

      describe "#friends_count" do
        it "is a Fixnum" do
          expect(@record_1.friends_count).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record_1.friends_count).to eq @hash_1[:friends_count]
        end

        it "is writable" do
          @record_1.friends_count = 0
          expect(@record_1.friends_count).to eq 0
        end
      end

      describe "#tweets_count" do
        it "is a Fixnum" do
          expect(@record_1.tweets_count).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record_1.tweets_count).to eq @hash_1[:tweets_count]
        end

        it "is writable" do
          @record_1.tweets_count = 0
          expect(@record_1.tweets_count).to eq 0
        end
      end

      describe "#favorites_count" do
        it "is a Fixnum" do
          expect(@record_1.favorites_count).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record_1.favorites_count).to eq @hash_1[:favorites_count]
        end

        it "is writable" do
          @record_1.favorites_count = 0
          expect(@record_1.favorites_count).to eq 0
        end
      end

      describe "#listed_count" do
        it "is a Fixnum" do
          expect(@record_1.listed_count).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record_1.listed_count).to eq @hash_1[:listed_count]
        end

        it "is writable" do
          @record_1.listed_count = 0
          expect(@record_1.listed_count).to eq 0
        end
      end

      describe "#recent_tweets" do
        it "is a Fixnum" do
          expect(@record_1.recent_tweets).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record_1.recent_tweets).to eq @hash_1[:recent_tweets]
        end

        it "is writable" do
          @record_1.recent_tweets = 0
          expect(@record_1.recent_tweets).to eq 0
        end
      end

      describe "#recent_mentions" do
        it "is a Fixnum" do
          expect(@record_1.recent_mentions).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record_1.recent_mentions).to eq @hash_1[:recent_mentions]
        end

        it "is writable" do
          @record_1.recent_mentions = 0
          expect(@record_1.recent_mentions).to eq 0
        end
      end

      describe "#recent_replies" do
        it "is a Fixnum" do
          expect(@record_1.recent_replies).to be_an_instance_of Fixnum
        end

        it "is readable" do
          expect(@record_1.recent_replies).to eq @hash_1[:recent_replies]
        end

        it "is writable" do
          @record_1.recent_replies = 0
          expect(@record_1.recent_replies).to eq 0
        end
      end
    end


    describe " - fields set on before_validation by #inspect_old_data and total_differences" do   
      it "has a readable/writable recent_friends" do
        expect{@record_1.recent_friends}.not_to raise_error
        @record_1.recent_friends = 1
        expect(@record_1.recent_friends).to be 1
      end

      it "has a readable/writable recent_followers" do
        expect{@record_1.recent_followers}.not_to raise_error
        @record_1.recent_followers = 1
        expect(@record_1.recent_followers).to be 1
      end

      it "has a readable/writable recent_favorites" do
        expect{@record_1.recent_favorites}.not_to raise_error
        @record_1.recent_favorites = 1
        expect(@record_1.recent_favorites).to be 1
      end

      it "has a readable/writable recent_lists" do
        expect{@record_1.recent_lists}.not_to raise_error
        @record_1.recent_lists = 1
        expect(@record_1.recent_lists).to be 1
      end

      it "has a readable/writable total_differences" do
        expect{@record_1.total_differences}.not_to raise_error
        @record_1.total_differences = 1
        expect(@record_1.total_differences).to be 1
      end
    end

    context " * until record_1 is saved " do
      it "has a readable created_at as nil" do
        expect(@record_1.created_at).to be nil
      end

      it "has a readable updated_at as nil" do
        expect(@record_1.updated_at).to be nil
      end
    end
  end

  describe " -- general field assignment methods -- " do
    
    before(:each) do
    @record_1.save #save the first record to have something to compare

    @hash_2 = {:screen_name=>"test-guy-2", :description=>"/Web Developer and Does-Weller/", :followers_count=>96, :friends_count=>314, :tweets_count=>1075, :favorites_count=>398, :listed_count=>2, :recent_tweets=>2, :recent_mentions=>1, :recent_replies=>1 }   
    @record_2 = TwitterRecord.new(@hash_2)
   
    end

    after(:each) do 
      TwitterRecord.find(@record_1.id).destroy #delete the saved request
    end

    # xdescribe "#assign_total_differences" do

    # end

    describe "#compare_friends_count" do
      context " * when there is a difference" do
        it "returns an integer" do
          expect(@record_2.compare_friends_count(@record_1.friends_count)).to be 3
        end

        it "assigns recent_friends as the difference" do
          the_difference = @record_2.compare_friends_count(@record_1.friends_count)

          expect(@record_2.recent_friends).to eq the_difference
        end
      end

      context " * when there is no difference" do
        it "returns nil" do
          expect(@record_1.compare_friends_count(@record_1.friends_count))
        end
      end
    end

    describe "#compare_followers_count" do
       context " * when there is a difference" do
        it "returns an integer" do
          expect(@record_2.compare_followers_count(@record_1.followers_count)).to be -2
        end

        it "assigns recent_followers as the difference" do
          the_difference = @record_2.compare_followers_count(@record_1.followers_count)

          expect(@record_2.recent_followers).to eq the_difference
        end
      end

      context " * when there is no difference" do
        it "returns nil" do
          expect(@record_1.compare_followers_count(@record_1.followers_count)).to be nil
        end
      end
    end

    describe "#compare_favorites_count" do
       context " * when there is a difference" do
        it "returns the difference as an Integer" do
          expect(@record_2.compare_favorites_count(@record_1.favorites_count)).to be 2
        end

        it "assigns recent_favorites as the difference" do
          the_difference = @record_2.compare_favorites_count(@record_1.favorites_count)
          expect(@record_2.recent_favorites).to eq the_difference
        end
      end

      context " * when there is no difference" do
        it "returns nil" do
          expect(@record_1.compare_favorites_count(@record_1.favorites_count)).to be nil
        end
      end
    end

    describe "#compare_lists_count" do
      context " * when there is a difference" do
        it "returns an integer" do
          expect(@record_2.compare_lists_count(@record_1.listed_count)).to be 2
        end

        it "assigns recent_listed as the difference" do
          the_difference = @record_2.compare_lists_count(@record_1.listed_count)
          expect(@record_2.recent_lists).to eq the_difference
        end
      end

      context " * when there is no difference" do
        it "returns nil" do
          expect(@record_1.compare_lists_count(@record_1.listed_count))
        end
      end
    end
  end

  describe "-- difference calculations --" do
    before(:each) do
      @differences = ["test-guy-2", -2, 3, 2, 2, 2, 1] 
    end

    describe "#sub_differences" do
      before(:each) do
        @subbed_array = @record_1.sub_differences(@differences)
      end

      context "when the difference is a string" do
        it "replaces it with a 1" do
          index_of_string = 0
          expect(@subbed_array[index_of_string]).to eq 1
        end
      context "when the difference is a negative integer" do
        it "it returns the absolute value of the integer" do
          index_of_negative = 1
          expect(@subbed_array[index_of_string]).to eq 2
        end
      end

      context "when the difference is a positive integer" do
        it "returns the absolut value of the integer" do
          index_of_positive = 2
          expect(@subbed_array(@differences)[index_of_positive]).to eq 3 
        end
      end
    end

    describe "#filter_differences" do

    end

    describe "#sum_up_differences" do

    end
  end
end
