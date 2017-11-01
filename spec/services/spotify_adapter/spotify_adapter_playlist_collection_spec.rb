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
  
end