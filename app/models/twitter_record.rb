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
      when "followers_count"
        if old_value != new_value
          self.recent_followers = difference(old_value,new_value)
        else
          nil
        end
      when "friends_count"
        if old_value != new_value
          self.recent_friends = difference(old_value,new_value)
        else
          nil
        end
      when "tweets_count"
        old_value
      when "favorites_count"
        if old_value != new_value
          self.recent_favorites = difference(old_value,new_value)
        else
          nil
        end
      when "listed_count"
        if old_value != new_value
          self.recent_lists = difference(old_value,new_value)
        else
          nil
        end
      when "current_status_id"
        old_value != new_value ? new_value : nil
      when "recent_tweets"
        old_value
      when "recent_mention"
        old_value
      when "recent_replies"
        old_value
      end
    end

    def difference(old_value, new_value)
      return old_value - new_value
    end
  end
end
