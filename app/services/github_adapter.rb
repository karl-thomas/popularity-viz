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
      repos: total_repos,
      gists: total_gists,
      followers: profile.followers,
      following: profile.following,
      starred_repos: starred_repos.count,
      recent_projects: recent_updated_repos(owned_repos).count
    }
  end

  def total_gists
    application_client
    profile.public_gists + profile.private_gists
  end

  def total_repos
    application_client
    profile.public_repos + profile.total_private_repos
  end

  # repo collections 
  def owned_repos
    application_client
    self.client.repos( self.user, affiliation: "owner" )
  end

  def collaborated_repos
    application_client
    self.client.repos( self.user, affiliation: "collaborator" )
  end

  def organizations_repos
    application_client
    self.client.repos( self.user, affiliation: "organization_member" )
  end

  def recent_updated_repos(repos)
    repos.select { |repo| repo[:pushed_at] > two_weeks_ago }
  end

  def starred_repos
    application_client
    self.client.starred(self.user)
  end

  # gists
  def recent_gists
    application_client
    self.client.gists( self.user, since: two_weeks_ago )
  end

  def recent_starred_gists
    personal_client
    self.client.starred_gists( since: two_weeks_ago )
  end

  # repo behaviour, returns recent info, these things should be in a repo class. 
  def collect_repo_data
    recent_repos.map {|repo| repo_data(repo[:full_name])}
  end

  def repo_data(repo_name)
    {
      recent_commits: recent_commits(repo_name).count,
      recent_comments: recent_commit_comments(repo_name).count,
      recent_deployments: recent_deployments(repo_name)
    }
  end

  def recent_commits(repo_name)
    application_client
    self.client.commits_since(repo_name, two_weeks_ago, author: self.user)
  end

  def all_commit_comments(repo_name)
    application_client
    self.client.list_commit_comments(repo_name)
  end

  def recent_commit_comments(repo_name)
    application_client
    comments = all_commit_comments(repo_name)
    return [] if comments.empty?
    comments.select { |comment| comment[:created_at] > two_weeks_ago }
  end

  def deployments(repo_name)
    application_client
    self.client.deployments(repo_name)
  end

  def recent_deployments(repo_name)
    application_client
    all_deployments = deployments(repo_name)
    return [] if deployments.empty?
    deployments.select { |deployments| deployments[:created_at] > two_weeks_ago }
  end

  # repo traffic, for all owned repos --------------
  def collect_traffic_data
    self.owned_repos.map {|repo| traffic_data(repo[:full_name]) }
  end

  def traffic_data(repo)
    {
      recent_views: recent_views_for_repo(repo)[:count],
      recent_clones: recent_clones_for_repo(repo)[:count]
    }  
  end

  def recent_clones_for_repo(repo_name)
    personal_client
    self.client.clones(repo_name, per: "week")
  end

  def recent_views_for_repo(repo_name)
    personal_client
    self.client.views(repo_name, per: "week")
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