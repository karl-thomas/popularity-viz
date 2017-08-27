class SpotifyAdapter
  attr_reader :user

  def initialize
    RSpotify.authenticate(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"] )
    @user = ENV['SPOTIFY_USERNAME']
  end

  def profile 
    @profile = RSpotify::User.find(self.user)
  end

  # for some reason you cant see track info from user.playlists, so you have to go find the playlists individually. 
  def playlist_ids
    self.profile.playlists.map { |playlist| playlist.id }
  end

  def full_playlist(id)
    RSpotify::Playlist.find(self.user, id)
  end

  def all_playlists
    array_of_ids = playlist_ids
    array_of_ids.map { |id| self.full_playlist(id) }
  end
end