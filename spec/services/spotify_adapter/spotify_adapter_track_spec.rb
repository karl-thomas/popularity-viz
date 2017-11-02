require "rails_helper"

RSpec.describe SpotifyAdapter::Track do 
  let(:criminal_image_id) { "5Exvn8HMcR5siCQ4DdD0Sa"}
  let(:old_track) { SpotifyAdapter::Track.new(criminal_image_id, 6.weeks.ago)} # old
  let(:recent_track) { SpotifyAdapter::Track.new(criminal_image_id, 1.week.ago)} # recent 

  it "should be assigned the correct class" do # more of an autoloading test
    expect(recent_track).to be_an_instace_of SpotifyAdapter::Track
  end 
end