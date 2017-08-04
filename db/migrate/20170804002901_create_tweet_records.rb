class CreateTweetRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :tweet_records do |t|

      t.timestamps
    end
  end
end
