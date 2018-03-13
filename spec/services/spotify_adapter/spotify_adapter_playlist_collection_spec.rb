require 'rails_helper'

RSpec.describe SpotifyAdapter::PlaylistCollection, :vcr do 
  let(:collection) { SpotifyAdapter.new.owned_playlists }
  
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
      track = collection.all_recent_tracks.first
      expect(track.added_at).to be > 2.weeks.ago
    end
  end

  describe "group_tracks_by_date", :vcr do
    it "returns an hash grouped by date" do
      date = collection.group_tracks_by_date.keys.first
      expect(expect(Date.parse(date))).to_not be nil
    end
  end 

  describe "count_of_tracks_by_date", :vcr do
    it "returns a list of number based on how many tracks were save on a date" do
      count = collection.count_of_tracks_by_date.values.first
      expect(count[:added_tracks]).to be_an_instance_of Integer
    end
  end
  
end

