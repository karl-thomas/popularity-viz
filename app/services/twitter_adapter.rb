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

  # note to karl, this gives you the count of the things below, very cool. 
  # so to take the count of thing, I can mostly use this. 
  def profile
    self.client.user(self.user_name)
  end

  # def test
  #   self.client.search("kerl since:#{@date_two_weeks_ago}").take(100).collect.to_a
  # end

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

  def followers
    self.client.followers(self.user_name, skip_status: 't')
  end

  def friends
    self.client.friends(self.user_name, skip_status: 't')
  end

  def favorites
    self.client.friend(self.user_name, count: 100)
  end

end
