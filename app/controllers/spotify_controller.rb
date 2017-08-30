class SpotifyController < ApplicationController
  def index
    redirect_to "http://google.com" if params[:rabbit] == ENV['RABBIT']
    @spotify_adapter = SpotifyAdapter.new
  end

   def spotify
    p " DID I DO IT PLEASE TELL MEEEEEEEEE"
    @spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    binding.pry
   end
end