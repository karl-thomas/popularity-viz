class SpotifyAdapter
  class Track < SpotifyAdapter
    attr_reader :id, :added_at, :full
    def initialize(id, date_added_to_playlist)
      super()
      @id = id
      @added_at = date_added_to_playlist  
    end

    def full
      @full ||= RSpotify::Track.find(id)
    end

    def recent?
      added_at > 2.weeks.ago
    end

  end
end
