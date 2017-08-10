require 'pry'
require 'octokit'

class GithubAdapter
  attr_reader :user, :client, :two_weeks_ago

  def initialize
    application_client
    @user = ENV['GITHUB_USERNAME'] 
    @two_weeks_ago = 2.weeks.ago.strftime("%Y-%m-%d")
  end

  def profile
    @profile ||= self.client.user(self.user)
  end 

  def profile_data
    {
      username: profile.login,
      public_repos: profile.public_repos,
      public_gists: profile.public_gists,
      followers: profile.followers,
      following: profile.following,
      starred_repos: self.starred_repos.count
    }
  end


  def owned_repos
    self.client.repos( self.user, affiliation: "owner" )
  end

  def collaborated_repos
    self.client.repos( self.user, affiliation: "collaborator" )
  end

  def organizations_repos
    self.client.repos( self.user, affiliation: "organization_member" )
  end

  def recent_updated_repos(repos)
    repos.select { |repo| repo[:pushed_at] > two_weeks_ago }
  end

  def starred_repos
    application_client
    self.client.starred(self.user)
  end

  def recent_gists
    self.client.gists( self.user, since: two_weeks_ago )
  end

  def recent_starred_gists
    personal_client
    self.client.starred_gists( since: two_weeks_ago )
  end

  # repo behaviour, these things should be in a repo class. 
  def recent_commits(repo_name)
    self.client.commits_since(repo_name, two_weeks_ago, author: self.user)
  end

  def all_commit_comments(repo_name)
    self.client.list_commit_comments(repo_name)
  end

  def recent_commit_comments(repo_name)
    comments = commit_comments(repo_name)
    return [] if comments.empty?
    comments.select { |comment| comment[:created_at] > two_weeks_ago }
  end

  def recent_clones_for_repo(repo_name)
    personal_client
    self.client.clones(repo_name, per: "week")
  end

  def recent_views_for_repo(repo_name)
    personal_client
    self.client.views(repo_name, per: "week")
  end

  def repo_data(repo_name)
    {
      recent_commits: recent_commits(repo_name).count,
      recent_comments: recent_comments(repo_name).count,
      recent_views: recent_views_for_repo(repo_name),
      recent_clones: recent_clones_for_repo(repo_name),
    }
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