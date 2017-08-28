class SpotifyController < ApplicationController
  before_action :set_adapter

 def callback
  @spotify_user = RSpotify::User.new(request.env['rack.request.query_hash']['code'])
  binding.pry
 end

  private

    def set_adapter
      @spotify_adapter = SpotifyAdapter.new
    end
end