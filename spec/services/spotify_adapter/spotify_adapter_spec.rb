require 'rails_helper'

RSpec.describe SpotifyAdapter do
  let(:adapter) { SpotifyAdapter.new }

  
  describe "#owned_playlists", :vcr do
    it "returns a playlist collection" do
      expect(adapter.owned_playlists).to be_an_instance_of SpotifyAdapter::PlaylistCollection
    end
  end

  describe "#full_track", :vcr do
    let(:criminal_image_id) { "5Exvn8HMcR5siCQ4DdD0Sa"}
    it "returns an instance of RSpotify::Track" do
      expect(adapter.full_track(criminal_image_id)).to be_an_instance_of RSpotify::Track
    end

    it "brings the whole track back from the spotify api" do
      expect(adapter.full_track(criminal_image_id).name).to eq "Criminal Image"
    end
  end

  describe "#recently_played" do
    it "returns a collection of tracks from the spotify api" do
      expect(adapter.recently_played.first).to be_an_instance_of Hash
    end

    it "each track has a valid id" do
      expect(adapter.recently_played.first["id"]).not_to be nil
    end
  end

  describe "#recommendation" do
    it "returns a has of song information" do
      expect(adapter.recommendation[:track]).not_to be nil
    end
  end


end