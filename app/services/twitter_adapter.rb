require 'twitter'

class TwitterAdapter
  autoload :TweetCollection, "twitter_adapter/tweet_collection"

  attr_reader :client, :user_name
  def initialize
    @user_name = ENV['TWITTER_USER']
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_TOKEN']
      config.access_token_secret = ENV['TWITTER_TOKEN_SECRET']
    end
    @date_two_weeks_ago = 2.weeks.ago.strftime("%Y-%m-%d")
  end

  def retrieve_profile
    self.client.user(self.user_name)
  end

  def aggregate_data_record
    self.formatted_profile
  end

  def counts_by_date
    recent_tweets.count_by_date
    .merge(recent_replies.count_by_date)
    .merge(recent_mentions.count_by_date)
  end

  def recent_tweets
    query = "from:#{self.user_name} since:#{@date_two_weeks_ago}"
    api_response = self.client.search(query).take(100).collect.to_a
    TweetCollection.new(api_response, :tweets)
  end

  def recent_replies
    query = "to:#{self.user_name} since:#{@date_two_weeks_ago}"
    api_response = self.client.search(query).take(100).collect.to_a
    TweetCollection.new(api_response, :replies)
  end

  def recent_mentions
    query = "@#{self.user_name} since:#{@date_two_weeks_ago}"
     api_response = self.client.search(query).take(100).collect.to_a
     TweetCollection.new(api_response, :mentions)
  end

  # def retrieve_followers(new_followers = 100)
  #   self.client.followers(self.user_name, skip_status: 't').take(new_followers)
  # end

  # def retrieve_friends(new_friends = 100 )
  #   self.client.friends(self.user_name, skip_status: 't').take(new_friends)
  # end

  # def retrieve_favorites(new_favorites = 100)
  #   self.client.favorites(self.user_name, count: new_favorites)
  # end

  def formatted_profile
    profile = self.retrieve_profile
    { 
      counts_by_date: counts_by_date,
      screen_name: profile.screen_name,
      description: profile.description,
      followers_count: profile.followers_count,
      friends_count: profile.friends_count,
      tweets_count: profile.statuses_count,
      favorites_count: profile.favorites_count,
      listed_count: profile.listed_count,
    }
  end
end
