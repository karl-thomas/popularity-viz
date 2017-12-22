class TweetCollection
  attr_reader :tweets, :mode
  COUNT_KEYS = {tweets: :tweets_written, replies: :replies_to_me, mentions: :mentions}

  def initialize(api_response_full_of_tweets, mode)
    @tweets = api_response_full_of_tweets
    @mode = mode
  end

  def retweets
    tweets.select { |t| t.retweet? }
  end

  def all_text
    tweets.map(&:text).join(" ")
  end

  def most_common(string = self.all_text)
    words = string.downcase.tr(",.?!",'').gsub('rt', '').split(' ')
    counts = words.each_with_object(Hash.new(0)) { |e, h| h[e] += 1 }
    max_quantity = counts.values.max
    counts.select { |k, v| v == max_quantity }.keys
  end

  def any_retweets?
    tweets.any? { |t| t.retweet? }
  end

  def grouped_by_date
    tweets.group_by { |tweet| tweet.created_at.to_date.to_s}
  end

  def count_by_date
    grouped_by_date.map {|date, tweets| [date, {self.class::COUNT_KEYS[mode] => tweets.count}] }.to_h
  end
end