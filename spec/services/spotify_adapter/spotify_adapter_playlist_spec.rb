require 'rails_helper'

RSpec.describe SpotifyAdapter::Playlist do
  let(:playlist) { SpotifyAdapter.new.owned_playlists.playlists[0] }
  it "is assigned to the correct class", :vcr do
    expect(playlist).to be_an_instance_of SpotifyAdapter::Playlist
  end


  describe "on initialization", :vcr do
    it "is assigned an id as a reader" do
      expect(playlist.id).not_to be nil
    end
  end

  describe "#tracks", :vcr do
    it "returns an array" do
      expect(playlist.tracks).to be_an_instance_of Array
    end

    it "assigns @tracks" do
      playlist.tracks
      expect(playlist.instance_variable_get(:@tracks)).not_to be nil
    end
  end

  describe "#recent?", :vcr do
    it "returns a boolean, if the playlist has been recently updated or not" do
      expect(playlist.recent?).to be(true).or(false)
    end
  end

  describe "#full", :vcr do
    it "returns the full playlist from the spotify api" do
      expect(playlist.full).to be_an_instance_of RSpotify::Playlist
    end

    it "needs to have #tracks_added_at" do
      expect(playlist.full.tracks_added_at).not_to be nil
    end

  end

  describe "#recent_tracks", :vcr do
    it "returns a hash" do
      expect(playlist.recent_tracks).to be_an_instance_of Hash
    end

    it "has keys of date objects, less than two weeks old" do
      date = playlist.recent_tracks.keys.first
      expect(date).to be > 2.weeks.ago
    end

    it "has strings of valid track ids for values" do
      id =  playlist.recent_tracks.values.first
      expect(id).to be_an_instance_of(String)
    end
  end

  describe "#create_tracks", :vcr do
    it "returns a collection of track Objs" do
      playlist.full.tracks
      expect(playlist.create_tracks.first).to be_an_instance_of SpotifyAdapter::Track
    end
  end
end