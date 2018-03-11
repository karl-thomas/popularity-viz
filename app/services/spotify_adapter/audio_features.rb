class AudioFeatures
  IMPORTANT_FEATURES = ["acousticness", "danceability", "duration_ms", "energy", "instrumentalness", "speechiness", "tempo", "valence"]

  attr_reader :features
  
  # makes an api request to gather audio feeatures, 
  # but they may not be there.
  def initialize(track)
    begin
      @features = track.audio_features
    rescue
      @features = nil
    end
  end

  # grab the most important features(useable) from the audio features, 
  # it does not operate like a hash, so you must send a method to the RSpotifys wrapper. 
  def important_features
    return nil if features.nil?
    @important_features ||= self.class::IMPORTANT_FEATURES.map do |feature| 
      [feature ,features.send(feature)] 
    end.to_h
  end
end