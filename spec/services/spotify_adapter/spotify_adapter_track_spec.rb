require "rails_helper"

RSpec.describe SpotifyAdapter::Track do 
  let(:criminal_image_id) { "5Exvn8HMcR5siCQ4DdD0Sa"}
  let(:more_weeks) {6.weeks.ago}
  let(:one_week_ago) {1.week.ago}
  let(:old_track) { SpotifyAdapter::Track.new(criminal_image_id, more_weeks)} # old
  let(:recent_track) { SpotifyAdapter::Track.new(criminal_image_id, one_week_ago)} # recent 

  context "when the tests start", :vcr do
    it "should be assigned the correct class" do # more of an autoloading test
      expect(recent_track).to be_an_instance_of SpotifyAdapter::Track
    end 
  end

  describe "on initialization", :vcr do
    it "should be assigned an id" do
      expect(recent_track.id).to eq criminal_image_id
    end

    it "should be assigned a date it was added to a playlist" do
      expect(recent_track.added_at).to eq one_week_ago
    end
  end

  describe "#recent?", :vcr do
    context "when recently added to a playlist", :vcr do
      it "should return true" do
         expect(recent_track.recent?).to eq true
      end
    end

    context "when not recently added to a playlist", :vcr do
      it "should return false" do
        expect(old_track.recent?).to eq false
      end
    end
  end

  describe "#full", :vcr do
    it "returns the full song from the spotify api" do
      expect(recent_track.full).to be_an_instance_of RSpotify::Track
    end
  end

  describe "#to_h", :vcr do
    it "returns a pretty hash version of the basic track data" do
      expect(recent_track.to_h[recent_track.added_at]).to eq recent_track.id
    end
  end

  describe "audioe features", :vcr do 
    it "returns a wrapped version of audio feature from the spotify api" do
      expect(recent_track.audio_features).to be_an_instance_of AudioFeatures
    end
  end
  
end