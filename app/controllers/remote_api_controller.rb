class RemoteApiController < ApplicationController
  
  def github_profile
    github_obj = GithubAdapter.new(ENV['GITHUB_USERNAME'], ENV['GITHUB_TOKEN'])
    render json: github_obj.request_all_info.to_json
  end

end