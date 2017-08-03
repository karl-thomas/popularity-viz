class GithubController < ApplicaitonController
  before_action :set_github_adapter

  def github_profile
    @api_response = @github_adapter.profile
    render json: @api_response.to_json
  end

  def recent_repos
    @api_response = @github_adapter.recent_repos
    render json: @api_response["items"].to_json
  end

  def recent_commits
    @api_response = @github_adapter.recent_commits
    render json: @api_response.parsed_response.to_json
  end

  private

    def set_github_adapter
      @github_adapter = GithubAdapter.new
    end

end
