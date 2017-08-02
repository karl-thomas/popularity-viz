require 'twitter'

class TwitterAdapter

  attr_reader :client, :user_name
  def initialize
    @user_name = ENV['TWITTER_USER']
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "YOUR_CONSUMER_KEY"
      config.consumer_secret     = "YOUR_CONSUMER_SECRET"
      config.access_token        = ENV['TWITTER_TOKEN']
      config.access_token_secret = "YOUR_ACCESS_SECRET"
    end
  end

  def profile
    self.client
  end
end