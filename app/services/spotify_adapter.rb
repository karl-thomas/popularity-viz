class SpotifyAdapter
  def initialize
    RSpotify.authenticate(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"] )
    @user = ENV['SPOTIFY_USERNAME']
  end

end