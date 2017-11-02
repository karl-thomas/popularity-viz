class SpotifyAdapter
  class Playlist < SpotifyAdapter
    attr_reader :id, :username

    def initialize(id)
      super()
      @id = id
    end

    def create_tracks
      full.tracks_added_at.map {|id,date| SpotifyAdapter::Track.new(id,date)}
    end

    # you need to call #tracks in order for tracks_added_at to update
    def tracks
      full.tracks
      @tracks ||= create_tracks
    end

    def recent?
      @recent ||= tracks.any? {|track| track.recent? }
    end

    def full
      @full ||= RSpotify::Playlist.find(username, id) 
    end

    def recent_tracks
      tracks
      @recent_tracks = tracks.select { |track| track.recent? }
    end
    

  end
end
