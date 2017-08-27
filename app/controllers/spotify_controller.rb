class SpotifyController < ApplicationController
  before_action :set_adapter

  def index
    render json: @spotify_adapter.profile
  end

  private

    def set_adapter
      @spotify_adapter = SpotifyAdapter.new
    end
end