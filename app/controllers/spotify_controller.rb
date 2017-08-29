class SpotifyController < ApplicationController
  before_action :set_adapter

  def start

  end

  def index
    redirect_to "https://accounts.spotify.com/authorize/?client_id=#{ENV['SPOTIFY_CLIENT_ID']}&response_type=code&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fauth%2Fspotify%2Fcallback&scope=user-read-private%20user-read-email%20user-library-read&state=rabbits"
  end

 def callback
  p "now im not"
  @spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
  binding.pry
 end

  private

    def set_adapter
      @spotify_adapter = SpotifyAdapter.new
    end
end