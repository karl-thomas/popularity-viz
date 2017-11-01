class SpotifyAdapter
  class PlaylistCollection < SpotifyAdapter
    attr_reader :playlists
    def initialize(playlists)
      @playlists = sanitize_playlists(playlists)
    end

    def sanitize_playlists(playlists)
      playlists.map { |pl| SpotifyAdapter::Playlist.new(pl.id)}
    end
  end

end