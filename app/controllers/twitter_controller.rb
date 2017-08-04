class TwitterController < ApplicationController
  before_action :set_twitter_adapter

  def profile
    @api_response = @twitter_adapter.retrieve_profile
    puts @api_response.methods.sort
    render json: @api_response.to_json
  end

  def formatted_profile
    @api_response = @twitter_adapter.formatted_profile
    render json: @api_response.to_json
  end

  def recent_tweets
    @api_response = @twitter_adapter.recent_tweets
    render json: @api_response
  end

  def recent_replies
    @api_response = @twitter_adapter.recent_replies
    render json: @api_response
  end

  def recent_followers
    # this is not returning the most recent followers, but all of them
    # once i can compare against the previous week, i can specify how many
    p @api_response = @twitter_adapter.retrieve_followers(10)
    render json: @api_response
  end

  def recent_friends
    # this is not returning the most recent followers, but all of them
    @api_response = @twitter_adapter.retrieve_friends(10)
    render json: @api_response
  end

  def recent_favorites
    p @api_response = @twitter_adapter.retrieve_favorites(10)
    render json: @api_response
  end

  private

    def set_twitter_adapter
      @twitter_adapter = TwitterAdapter.new
    end
end