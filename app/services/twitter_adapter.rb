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

  def profile
    self.client.user(self.user_name)
  end

  def recent_tweets
    p self.user_name
    self.client.search("from:#{self.user_name} since:#{@date_two_weeks_ago}").take(100).collect.to_a
  end

  def recent_tweeteds
    self.client.search("to:#{self.user_name} since:#{@date_two_weeks_ago}").take(100).collect.to_a
  end
end
