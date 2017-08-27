class SpotifyAdapter
  attr_reader :user

  def initialize
    RSpotify.authenticate(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"] )
    @user = ENV['SPOTIFY_USERNAME']
  end

  def profile 
    RSpotify::User.find(self.user)
  end

end