require 'rails_helper'

RSpec.describe SpotifyAdapter do
  let(:adapter) { SpotifyAdapter.new }

  
  describe "#owned_playlists" do
    it "returns a playlist colelction" do
      expect(adapter.owned_playlists).to be_an_instance_of SpotifyAdapter::PlaylistCollection
    end
  end

end