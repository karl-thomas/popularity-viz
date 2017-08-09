require 'pry'
require 'octokit'

class GithubAdapter
  attr_reader :user, :client

  def initialize
    application_client
    @user = ENV['GITHUB_USERNAME'] 
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
      following: profile.following,
      starred_repos: self.starred_repos.count
    }
  end

  def starred_repos
    application_client
    self.client.starred(self.user)
  end

  def recent_views_for_repo(exact_repo_name)
    personal_client
    self.client.views(exact_repo_name, per: "week")
  end

  def recent_clones_for_repo(exact_repo_name)
    personal_client
    self.client.clones(exact_repo_name, per: "week")
  end

  private
    def application_client
      if !self.client || self.client.client_id.nil?
        @client  = Octokit::Client.new \
          :client_id     => ENV['GITHUB_CLIENT_ID'],
          :client_secret => ENV['GITHUB_CLIENT_SECRET']
      end    
    end

    def personal_client
      if !self.client || self.client.login.nil?
        @client = Octokit::Client.new \
          :login => ENV['GITHUB_USERNAME'],
          :password => ENV['GITHUB_PASSWORD']
      end
    end
end