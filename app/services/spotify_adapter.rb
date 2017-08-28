class SpotifyAdapter
  attr_reader :user, :two_weeks_ago
  IMPORTANT_FEATURES = ["acousticness", "danceability", "duration_ms", "energy", "instrumentalness", "liveness", "loudness", "speechiness", "tempo", "valence"]
  
  def initialize
    RSpotify.authenticate(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"] )
    @user = ENV['SPOTIFY_USERNAME']
    @two_weeks_ago = 2.weeks.ago.strftime("%Y-%m-%d")
  end

  def profile 
    @profile ||= RSpotify::User.find(self.user)
  end

  def aggregate_data

    {
      recent_playlists: recent_playlists.count,
      recently_added_tracks: recently_added_track_ids.count
    }
  end

  def owned_playlists_short
    self.profile.playlists.select { |playlist| playlist.owner.id == self.user }
  end

  # for some reason you cant see track info from user.playlists, so you have to go find the playlists individually. 
  def playlist_ids(playlists)
    playlists.map { |playlist| playlist.id }
  end

  # access full playlist info
  def full_playlist(id)
    RSpotify::Playlist.find(self.user, id)
  end

  def owned_playlists_full
    incomplete_playlists = self.owned_playlists_short 
    array_of_ids = playlist_ids(incomplete_playlists)
    array_of_ids.map { |id| self.full_playlist(id) }
  end

  def recent_playlists 
    playlists = self.owned_playlists_full
    @recent_playlists ||= playlists.select { |playlist| recently_updated?(playlist) }
  end

  def recently_updated?(playlist)
    playlist.tracks_added_at.any? { |track, added_at| added_at > two_weeks_ago }
  end

  def recently_added_track_ids
    recent_playlists.flat_map {|playlist| recent_tracks(playlist) }
  end

  def recent_tracks(playlist)
    playlist.tracks_added_at.keys.select {|key| playlist.tracks_added_at[key] > two_weeks_ago}
  end

  def find_tracks(array_of_ids)
    RSpotify::Track.find(array_of_ids)
  end
    

  def average_audio_features
    tracks = find_tracks(recently_added_track_ids)
    tracks.reduce(Hash.new(0)) do |aggregate, track|
      IMPORTANT_FEATURES.each do |feature|
        value = track.audio_features.instance_variable_get("@#{feature}")
        aggregate["average_#{feature}"] += value
      end
      aggregate
    end
  end

end