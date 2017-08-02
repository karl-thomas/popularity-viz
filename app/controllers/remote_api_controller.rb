class RemoteApiController < ApplicationController
  before_action :set_github_adapter, only: [:github_profile,
                                            :recent_repos,
                                            :recent_commits]

  before_action :set_linkedin_adapter, only: [:linkedin_profile]

  before_action :set_twitter_adapter, only: [:twitter_profile,
                                             :recent_tweets,
                                             :recent_replies]


  # ============ GITHUB ACTIONS =================
  def github_profile
    @api_response = @github_adapter.profile
    render json: @api_response.to_json
  end

  def recent_repos
    @api_response = @github_adapter.recent_repos
    render json: @api_response["items"].to_json
  end

  # ******* under construction *******
  def recent_commits
    @api_response = @github_adapter.recent_commits
    render json: @api_response.parsed_response.to_json
  end
  # ******* end of construction ******

  # ============ LINKEDIN ACTIONS ===============
  def linkedin_profile
    @api_response = @linkedin_adapter.profile
    render json: @api_response
  end

  # ============ TWITTER ACTIONS =================
  def twitter_profile
    @api_response = @twitter_adapter.profile
    p @api_response.methods.sort
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

  private

    def set_github_adapter
      @github_adapter = GithubAdapter.new
    end

    def set_linkedin_adapter
      @linkedin_adapter = LinkedinAdapter.new
    end

    def set_twitter_adapter
      @twitter_adapter = TwitterAdapter.new
    end
end
