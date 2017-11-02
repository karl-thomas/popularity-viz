require 'rails_helper'

RSpec.describe SpotifyAdapter::PlaylistCollection do 
  let(:collection) {SpotifyAdapter.new.owned_playlists}
  
  it "is the valid class", :vcr do
    expect(collection).to be_an_instance_of SpotifyAdapter::PlaylistCollection
  end

  describe "on initialization", :vcr do
    it "is assigned a collection of playlist objects" do
      expect(collection.playlists.first).to be_an_instance_of SpotifyAdapter::Playlist
    end
  end

  describe "#all_recent_tracks", :vcr do
    it "returns an Array" do
      expect(collection.all_recent_tracks).to be_an_instance_of Array
    end

    it "has keys of a valid date" do
      date = collection.all_recent_tracks.keys.first
      expect(date).to be_an_instance_of Time
    end
  end
  
end

