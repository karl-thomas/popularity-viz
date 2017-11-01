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

  end

  describe "#full", :vcr do

  end

  describe "#recent_tracks", :vcr do

  end

end