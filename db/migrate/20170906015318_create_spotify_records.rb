class CreateSpotifyRecords < ActiveRecord::Migration[5.1]
  enable_extension 'hstore' unless extension_enabled?('hstore')
  def change
    create_table :spotify_records do |t|
      t.integer :recent_playlists 
      t.integer :recently_added_tracks
      t.string :most_occuring_feature
      t.integer :average_energy
      t.hstore :top_track
      t.integer :recent_genres  
      t.string :interesting_genre
      t.integer :saved_albums
      t.integer :recent_saved_albums
      
      t.timestamps
    end
  end
end
