class GithubAdapter < ApplicationController
  def initialize
    @user = Octokit.user('karl-thomas')
  end

  def request
  end 
end