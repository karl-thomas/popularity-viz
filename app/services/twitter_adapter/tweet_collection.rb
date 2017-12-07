class TweetCollection
  attr_accessor :tweets
  def initialize(api_response_full_of_tweets)
    @tweets = api_response_full_of_tweets
  end

   def grouped_by_date
    tweets.group_by { |tweet| tweet.created_at.to_date.to_s}
  end

  def count_by_date
    grouped_by_date.map {|date, tweets| [date, {tweets_written: tweets.count}] }.to_h
  end
end