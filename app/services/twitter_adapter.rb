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
  end

  def profile
    self.client.user(self.user_name)
  end
end
