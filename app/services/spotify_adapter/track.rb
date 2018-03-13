require_relative 'audio_features'

class SpotifyAdapter
  class Track < SpotifyAdapter
    
    attr_reader :id, :added_at, :full
    
    def initialize(id, date_added_to_playlist)
      @id = id
      @added_at = date_added_to_playlist  
    end

    def full
      authenticate
      @full ||= RSpotify::Track.find(id)
    end

    def recent?
      added_at > 2.weeks.ago
    end

    def to_h
      {added_at => id}
    end
    
    def audio_features
        AudioFeatures.new(full)
    end

    alias_method :audio, :audio_features 
  end
end
