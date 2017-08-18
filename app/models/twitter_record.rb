class TwitterRecord < ApplicationRecord
  before_validation :inspect_old_data, :assign_total_differences
  
  attr_accessor :differences

  def inspect_old_data
    last_record = TwitterRecord.last || self #for when it is the first element
    old_data = last_record.attributes
    # use each pair to check old data against new data
    @differences = old_data.map do |column_name, old_value| 
      new_value = self.send(column_name)
      assign_differences(column_name, old_value, new_value)
    end
  end


  def assign_total_differences
    valid_differences = filter_differences(self.differences)
    valid_differences = sub_differences(valid_differences)
    self.total_differences = sum_up_differences(valid_differences)
  end

  def assign_differences(column_name, old_value, new_value)
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
    if old_value != self.friends_count
      self.recent_friends = difference(old_value,self.friends_count)
    else
      nil
    end
  end

  def compare_followers_count(old_value)
    if old_value != self.followers_count
      self.recent_followers = difference(old_value,self.followers_count)
    else
      nil
    end
  end

  def compare_favorites_count(old_value)
    if old_value != self.favorites_count
      self.recent_favorites = difference(old_value,self.favorites_count)
    else
      nil
    end
  end

  def compare_lists_count(old_value)
    if old_value != self.listed_count
      self.recent_lists = difference(old_value,self.listed_count)
    else
      nil
    end
  end

  def sub_differences(differences)
    p differences
    differences.map { |diff| diff.class == String ? 1 : diff.abs }
  end

  def filter_differences(differences)
    differences.reject { |diff| diff.nil? }
  end

  def sum_up_differences(differences)
    differences.reduce(:+)
  end

  private
    def difference(old_value, new_value)
      return new_value - old_value
    end
end
