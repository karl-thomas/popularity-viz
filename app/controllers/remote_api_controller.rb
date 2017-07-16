class RemoteApiController < ApplicationController
  before_action :set_github_obj, only: [:github_profile, :github_repos]

  def github_profile
    render json: @github_obj.profile.to_json
  end

  def github_repos
    render json: @github_obj.recent_repos.to_json
  end

  private

    def set_github_obj
      @github_obj = GithubAdapter.new(ENV['GITHUB_USERNAME'])
    end
end