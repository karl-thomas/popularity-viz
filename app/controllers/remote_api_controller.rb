class RemoteApiController < ApplicationController
  before_action :set_github_adapter, only: [:github_profile, 
                                            :recent_repos,
                                            :recent_commits]

  before_action :set_linkedin_adapter, only: [:linkedin_profile]

  # ============ GITHUB ACTIONS =================
  def github_profile
    @api_response = @github_adapter.profile
    render json: @api_response.parsed_response.to_json
  end

  def recent_repos
    render json: @github_adapter.recent_repos.to_json
  end

  # ******* under construction *******
  def recent_commits
    render json: @github_adapter.all_recent_commits.to_json
  end
  # ******* end of construction ******

  # ============ LINKEDIN ACTIONS ===============
  def linkedin_profile
    render json: @linkedin_adapter.profile
  end

  private

    def set_github_adapter
      @github_adapter = GithubAdapter.new
    end

    def set_linkedin_adapter
      @linkedin_adapter = LinkedinAdapter.new
    end
end