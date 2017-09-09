module TwitterCalcs
  def inspect_old_data
    p 'start of inspec'
    p "last record"
    p old_data = Post.last.twitter_record || self.twitter_record #for when it is the first element
    # use each pair to check old data against new data
    @differences = old_data.map do |column_name, old_value| 
      p "mapping #{column_name} with value #{old_value}"
      p new_value = self.twitter_record[column_name.to_sym]
      assign_twitter_differences(column_name, old_value, new_value)
    end
  end


  def assign_total_differences
    p 'in assigning total_ diffes'
    valid_differences = filter_twitter_differences(self.differences)
    valid_differences = sub_differences(valid_differences)
    self.twitter_record['total_differences'] = sum_up_differences(valid_differences)
  end

  def assign_twitter_differences(column_name, old_value, new_value)
    p "working with #{column_name} with an old_value of #{old_value} and new of #{new_value}"
    case column_name
      when "screen_name"
        old_value != new_value ? new_value : nil
      when "description"
        old_value != new_value ? new_value : nil
      when "current_status_id"
        old_value != new_value ? new_value : nil
      when "followers_count"
        compare_followers_count(old_value)
      when "friends_count"
        compare_friends_count(old_value)
      when "favorites_count"
        compare_favorites_count(old_value)
      when "listed_count"
        compare_lists_count(old_value)
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

  def compare_friends_count(old_value)
    if old_value != self.twitter_record[:friends_count]
      p 'recent friends assigning'
      binding.pry
      self.twitter_record['recent_friends'] = difference(old_value, self.twitter_record[:friends_count])
    else
      nil
    end
  end

  def compare_followers_count(old_value)
    if old_value != self.twitter_record[:followers_count]
      self.twitter_record['recent_followers'] = difference(old_value,self.twitter_record[:followers_count])
    else
      nil
    end
  end

  def compare_favorites_count(old_value)
    if old_value != self.twitter_record[:favorites_count]
      p 'recent followers assigning'
      self.twitter_record['recent_favorites'] = difference(old_value,self.twitter_record[:favorites_count])
    else
      nil
    end
  end

  def compare_lists_count(old_value)
    if old_value != self.twitter_record[:listed_count]
      p 'recent lists assigning'
      self.twitter_record['recent_lists ']= difference(old_value,self.twitter_record[:listed_count])
    else
      nil
    end
  end

  def sub_differences(differences)
    p 'subbing differences'
    differences.map { |diff| diff.class == String ? 1 : diff.abs }
  end

  def filter_twitter_differences(differences)
    p 'filtering twitter diffs'
    differences.reject { |diff| diff.nil? }
  end

  def sum_up_differences(differences)
    p 'summing differences'
    differences.reduce(:+)
  end

  private
    def difference(old_value, new_value)
      p "subtracting #{old_value} from #{new_value}"
      return new_value - old_value
    end
end