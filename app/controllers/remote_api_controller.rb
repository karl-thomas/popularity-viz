class RemoteApi < ApplicationController
  def github
    @github_obj = Github.new(ENV['GITHUB_USERNAME'], ENV['GITHUB_TOKEN'])
  end
end