class AddRecentActionsToTwitterRecord < ActiveRecord::Migration[5.1]
  def change
    add_column :twitter_records, :recent_friends, :integer
    add_column :twitter_records, :recent_followers, :integer
    add_column :twitter_records, :recent_favorites, :integer
    add_column :twitter_records, :recent_lists, :integer
    add_column :twitter_records, :total_differences, :integer
  end
end
