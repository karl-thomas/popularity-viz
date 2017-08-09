require 'pry'
require 'octokit'

class GithubAdapter
  attr_reader :user, :client

  def initialize
    @user = ENV['GITHUB_USERNAME'] 
    @client = Octokit::Client.new \
      :client_id     => ENV['GITHUB_CLIENT_ID'],
      :client_secret => ENV['GITHUB_CLIENT_SECRET']

    @date_two_weeks_ago = 2.weeks.ago.strftime("%Y-%m-%d")
  end

  def retrieve_profile
    @profile ||= self.client.user(self.user)
  end 

  def profile_data
    {
      public_repos: profile.public_repos,
      public_gists: profile.public_gists,
      followers: profile.followers,
      following: profile.following
    }
  end

  def starred_repos
    self.client.starred(self.user)
  end

  def recent_starred_repos
    repos = self.starred_repos
    binding.pry
  end


end