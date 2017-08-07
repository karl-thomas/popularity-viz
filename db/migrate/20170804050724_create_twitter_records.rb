class CreateTwitterRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :twitter_records do |t|
      t.string :screen_name 
      t.string :description 
      t.integer :followers_count 
      t.integer :friends_count 
      t.integer :tweets_count 
      t.integer :favorites_count
      t.integer :listed_count
      t.integer :recent_tweets
      t.integer :recent_mentions
      t.integer :recent_replies   

      t.timestamps
    end
  end
end
