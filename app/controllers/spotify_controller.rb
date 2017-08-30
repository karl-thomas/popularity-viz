class SpotifyController < ApplicationController
  # before_action :set_adapter

  def index
    @spotify_adapter = SpotifyAdapter.new
  end

 def spotify
  p " DID I DO IT PLEASE TELL MEEEEEEEEE"
  @spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
  binding.pry
 end

  # private

  #   def set_adapter
  #     @spotify_adapter = SpotifyAdapter.new
  #   end
end