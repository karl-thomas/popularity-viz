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

  # note to karl, this gives you the count of the things below, very cool. 
  # so to take the count of thing, I can mostly use this. 
  def full_profile
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

  def retrieve_followers
    self.client.followers(self.user_name, skip_status: 't')
  end

  def retrieve_friends
    self.client.friends(self.user_name, skip_status: 't')
  end

  def retrieve_favorites
    self.client.favorites(self.user_name, count: 1)
  end

  def formatted_profile
    profile = self.profile
    {   
        screen:
        description: profile.description
        followers_count: profile.followers_count,
        friends_count: profile.friends_count,
        tweets_count: profile.statuses_count,
        favorites_count: profile.favorites_count,
        listed_count: profile.listed_count
        status_id: profile.status.id
    }
  end
end
