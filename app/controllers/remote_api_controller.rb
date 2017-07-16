class RemoteApiController < ApplicationController
  before_action :set_github_adapter, only: [:github_profile, 
                                            :recent_repos,
                                            :recent_commits]

  def github_profile
    render json: @github_adapter.profile.to_json
  end

  def recent_repos
    render json: @github_adapter.recent_repos.to_json
  end

  def recent_commits
    render json: @github_adapter.recent_commits.to_json
  end

  private

    def set_github_adapter
      @github_adapter = GithubAdapter.new(ENV['GITHUB_USERNAME'])
    end
end