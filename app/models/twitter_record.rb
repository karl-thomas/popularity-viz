class TwitterRecord < ApplicationRecord
  def initialize(args={})
    super(args)
    @twitter_adapter = TwitterAdapter.new
  end

  def compare_last_records_data
    old_record = TweetRecord.last
    old_data = old_record.attributes
    # sue each pair to check old data against new data

    old_data.map do |column_name, value|
      case column_name
      when "screen_name"
        self.send(column_name) if value != self.send(column_name)
        nil
      when "description"
        self.send(column_name) if value != self.send(column_name)
        nil
      when "followers_count"
      end
    end
  end
end
