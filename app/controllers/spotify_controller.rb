class SpotifyController < ApplicationController
  def index
    # return redirect_to "http://google.com" if params[:rabbit] == "no"
    @spotify_adapter = SpotifyAdapter.new
  # render body: "hey"
  end

   def spotify
    @spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    binding.pry
   end
end