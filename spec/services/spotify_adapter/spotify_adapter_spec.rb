require 'rails_helper'

RSpec.describe SpotifyAdapter, :vcr do
  let(:adapter) { SpotifyAdapter.new }

  describe "#owned_playlists", :vcr do
    it "returns a playlist collection" do
      expect(adapter.owned_playlists).to be_an_instance_of SpotifyAdapter::PlaylistCollection
    end
  end

  describe "#recently_played", :vcr do
    it "returns a collection of tracks from the spotify api" do
      expect(adapter.recently_played.first).to be_an_instance_of Hash
    end

    it "each track has a valid id" do
      expect(adapter.recently_played[0]["track"]["id"]).not_to be nil
    end
  end

  describe "#recommendation", :vcr do
    it "returns a hash of song information" do
      expect(adapter.recommendation[:track]).not_to be nil
    end
  end

  describe "#aggregate_data_record", :vcr do
    it "returns an aggregate to send tot he db" do
      expect(adapter.aggregate_data_record).to be_an_instance_of Hash
    end
  end

  describe "#artists", :vcr do
    it "retrieves artists from a list of tracks" do
      tracks = adapter.recently_played
      artists = adapter.artists(tracks)
      expect(artists.first).to be_an_instance_of RSpotify::Artist
    end
  end

  describe "#recent_genres", :vcr do
    it "flattens genre into one uniq array" do
      tracks = adapter.recently_played
      artists = adapter.artists(tracks)
      genres = adapter.recent_genres(artists)
      expect(genres.first).to be_an_instance_of String
    end
  end

  describe "all_recent_tracks", :vcr do 
    it "gives back an collection of tracks" do
      expect(adapter.all_recent_tracks).to be_an_instance_of SpotifyAdapter::Playlist
    end

    it "only has recent tracks" do
      expect(adapter.all_recent_tracks.tracks.first.added_at).to be > 2.weeks.ago
    end
  end
end