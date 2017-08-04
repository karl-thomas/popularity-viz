require 'twitter'
require 'pry'
class TwitterAdapter

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

  def recent_tweets
    query = "from:#{self.user_name} since:#{@date_two_weeks_ago}"
    self.client.search(query).take(100).collect.to_a
  end

  def recent_replies
    query = "to:#{self.user_name} since:#{@date_two_weeks_ago}"
    self.client.search(query).take(100).collect.to_a
  end

  def recent_mentions
    query = "@#{self.user_name} since:#{@date_two_weeks_ago}"
    self.client.search(query).take(100).collect.to_a
  end

  def retrieve_followers(new_followers)
    self.client.followers(self.user_name, skip_status: 't')
  end

  def retrieve_friends(new_friends)
    self.client.friends(self.user_name, skip_status: 't')
  end

  def retrieve_favorites(new_favorites)
    self.client.favorites(self.user_name, count: 40)
  end

  def formatted_profile
    profile = self.profile
    {   
        screen_name: profile.screen_name,
        description: profile.description,
        followers_count: profile.followers_count,
        friends_count: profile.friends_count,
        tweets_count: profile.statuses_count,
        favorites_count: profile.favorites_count,
        listed_count: profile.listed_count,
        current_status_id: profile.status.id
    }
  end

  def tweet_counts
    {
      recent_tweets: self.recent_tweets.count,
      recent_mentions: self.recent_mentions.count,
      replies: self.recent_replies.count
    }
  end

  def aggregate_user_data
    #the idea here will be to pair the profile info with data out side of the profile
    # mainly the data from other tweets, and merge that data together and save it 
    # in my database, i then can use whats in the database and compare it to the next polling
    profile_info = self.formatted_profile
    tweet_info = self.tweet_counts
    #then i'll merge em
  end
end
