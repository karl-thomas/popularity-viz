class TwitterRecord < ApplicationRecord
  def initialize
    @twitter_adapter = TwitterAdapter.new
  end

  def compare_last_records_data
    @old_record = TweetRecord.last
  end
end
