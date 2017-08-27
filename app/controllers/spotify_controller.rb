class SpotifyController < ApplicationController
  before_each :set_adapter
  
  def index
    
  end

  private

    def set_adapter
      @spotify_adapter = SpotifyAdapter.new
    end
end