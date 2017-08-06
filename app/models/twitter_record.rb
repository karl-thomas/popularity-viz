class TwitterRecord < ApplicationRecord
  def initialize(args={})
    super(args)
    @twitter_adapter = TwitterAdapter.new
  end

  def compare_last_records_data
    old_record = TweetRecord.last
    old_data = old_record.attributes
    updated_data = @twitter_adapter.aggregate_user_data
    # sue each pair to check old data against new data

    old_data.each_pair do |column_name, value|
      case column_name
      when "screen_name"
        updated_data[column_name] if old_data[column_name] != updated_data[column_name.to_sym]
        nil
      when "description"
        updated_data[column_name] if old_data[column_name] != updated_data[column_name.to_sym]
        nil
      when "followers_count"
      end
    end
  end
end
