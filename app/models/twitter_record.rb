class TwitterRecord < ApplicationRecord

  def initialize(args={})
    super(args)
    @twitter_adapter = TwitterAdapter.new
  end

  def compare_last_records_data
    old_record = TweetRecord.last
    old_data = old_record.attributes
    # sue each pair to check old data against new data
    old_data.map do |column_name, old_value|
      new_value = self.send(column_name)

      case column_name
      when "screen_name"
        old_value != new_value ? new_value : nil
      when "description"
        old_value != new_value ? new_value : nil
      when "current_status_id"
        old_value != new_value ? new_value : nil
      when "followers_count"
        compare_followers_count(old_value, new_value)
      when "friends_count"
        compare_friends_count(old_value, new_value)
      when "favorites_count"
        compare_favorites_count(old_value, new_value)
      when "listed_count"
        compare_lists_count(old_value, new_value)
      when "tweets_count"
        new_value
      when "recent_tweets"
        new_value
      when "recent_mention"
        new_value
      when "recent_replies"
        new_value
      else
        nil
      end
    end
  end

  def compare_friends_count(old_value, new_value)
    if old_value != new_value
      self.recent_friends = difference(old_value,new_value)
    else
      nil
    end
  end

  def compare_followers_count(old_value, new_value)
    if old_value != new_value
      self.recent_followers = difference(old_value,new_value)
    else
      nil
    end
  end

  def compare_favorites_count(old_value, new_value)
    if old_value != new_value
      self.recent_favorites = difference(old_value,new_value)
    else
      nil
    end
  end

  def compare_lists_count(old_value, new_value)
    if old_value != new_value
      self.recent_lists = difference(old_value,new_value)
    else
      nil
    end
  end

  def difference(old_value, new_value)
    return new_value - old_value
  end
end
