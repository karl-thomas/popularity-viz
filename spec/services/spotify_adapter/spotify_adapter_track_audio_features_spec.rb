require "rails_helper"

RSpec.describe SpotifyAdapter::Track::AudioFeatures, :vcr do 
  let(:criminal_image_id) { "5Exvn8HMcR5siCQ4DdD0Sa"}
  let(:time) {1.weeks.ago}
  let(:track) { SpotifyAdapter::Track.new(criminal_image_id, time)}

  describe "initialization", :vcr do
    context "when the track has audio features on spotify", :vcr do
      it "makes a request to the spotify api for audo featues" do
        features = track.audio_features
        assert_requested :get, "https://api.spotify.com/v1/audio-features/#{criminal_image_id}"
      end

      it "assigns data from this Rspotify Wrapper to features" do
        features = track.audio_features
        expect(features.features).to be_an_instance_of RSpotify::AudioFeatures
      end
    end
  end

  describe "important features" do
    it "returns a hash of useful audio data" do
      features = track.audio_features
      expect(features.important_features).to be_an_instance_of Hash
    end
  end
end

