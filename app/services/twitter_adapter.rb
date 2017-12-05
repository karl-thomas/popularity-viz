require 'twitter'

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

  def aggregate_data_record
    profile_info = self.formatted_profile
    tweet_info = self.recent_tweet_counts
    profile_info.merge(tweet_info)
  end

  def recent_tweets
    query = "from:#{self.user_name} since:#{@date_two_weeks_ago}"
    self.client.search(query).take(100).collect.to_a
  end

  def tweets_grouped_per_closed
    recent_tweets.group_by { |tweet| tweet.created_at.to_date.to_s}
  end

  def tweets_count_for_closed
    tweets_grouped_per_closed.map {|date, tweets| [date, {closed_pull_request: pulls.count}] }.to_h
  end

  def recent_replies
    query = "to:#{self.user_name} since:#{@date_two_weeks_ago}"
    self.client.search(query).take(100).collect.to_a
  end

  def recent_mentions
    query = "@#{self.user_name} since:#{@date_two_weeks_ago}"
    self.client.search(query).take(100).collect.to_a
  end

  def retrieve_followers(new_followers = 100)
    self.client.followers(self.user_name, skip_status: 't').take(new_followers)
  end

  def retrieve_friends(new_friends = 100 )
    self.client.friends(self.user_name, skip_status: 't').take(new_friends)
  end

  def retrieve_favorites(new_favorites = 100)
    self.client.favorites(self.user_name, count: new_favorites)
  end

  def formatted_profile
    profile = self.retrieve_profile
    {   
      screen_name: profile.screen_name,
      description: profile.description,
      followers_count: profile.followers_count,
      friends_count: profile.friends_count,
      tweets_count: profile.statuses_count,
      favorites_count: profile.favorites_count,
      listed_count: profile.listed_count,
    }
  end

  def recent_tweet_counts
    {
      recent_tweets: self.recent_tweets.count,
      recent_mentions: self.recent_mentions.count,
      recent_replies: self.recent_replies.count
    }
  end


end
