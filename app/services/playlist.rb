class SpotifyAdapter
  class Playlist < SpotifyAdapter
    attr_reader :id, :username

    def initialize(id)
      super()
      @id = id
    end

    def tracks
      @tracks ||= full.tracks
    end

    # you need to call #tracks in order for tracks_added_at to update
    def recent?
      return @recent if @recent
      tracks
      @recent = full.tracks_added_at.any? {|track, added_at| added_at > 2.weeks.ago}
    end

    def full
      @full ||= RSpotify::Playlist.find(username, id) 
    end

    def recent_tracks
      tracks
      @recent_tracks = 
      full.tracks_added_at
        .map { |id,date| [date, id] if date > 2.weeks.ago }
        .compact
        .to_h
    end
    
  end
end