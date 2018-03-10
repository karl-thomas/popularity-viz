class AudioFeatures
  def initialize(track)
    begin
      @features = track.audio_features
    rescue
      @features = nil
    end
  end

  def important_features
  end
end