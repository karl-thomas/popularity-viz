class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.jsonb :spotify_record, null: false, default: '{}'
      t.jsonb :github_record, null: false, default: '{}'
      t.jsonb :twitter_record, null: false, default: '{}'
      t.jsonb :insights, null: false, default: '{}'
      t.integer :total_interactions
      t.string :title

      t.timestamps
    end
  end
end
