class TwitterRecord < ApplicationRecord
  def initialize(args={})
    super(args)
    @twitter_adapter = TwitterAdapter.new
  end

  def compare_last_records_data
    old_record = TweetRecord.last
    old_data = old_record.attribute
    # sue each pair to check old data against new data
    
    old_data.each_pair
  end
end
