require 'pry'
require 'octokit'

class GithubAdapter
  attr_reader :user, :client, :two_weeks_ago

  def initialize
    @user = ENV['GITHUB_USERNAME'] 
    @two_weeks_ago = 2.weeks.ago.strftime("%Y-%m-%d")
  end

  def client
    @client ||= application_client
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

  def repo_data(repository_hash)
    repo = Repo.new(repository_hash)
    {
      recent_commits: recent_commits(repo).count,
      recent_comments: recent_comments(commit_comments(repo)).count,
      recent_views: recent_views_for_repo(repo),
      recent_clones: recent_clones_for_repo(repo),
    }
  end

  def owned_repos
    self.client.repos(self.user, affiliation: "owner")
  end

  def collaborated_repos
    self.client.repos(self.user, affiliation: "collaborator")
  end

  def organizations_repos
    self.client.repos(self.user, affiliation: "organization_member")
  end

  def recent_updated_repos(repos)
    repos.select { |repo| repo[:pushed_at] > two_weeks_ago }
  end

  def starred_repos
    application_client
    self.client.starred(self.user)
  end

  def recent_commits(repo)
    self.client.commits_since(repo, two_weeks_ago, author: self.user)
  end

  def commit_comments(repo)
    self.client.list_commit_comments(repo)
  end

  def recent_comments(comments)
    return [] if comments.empty?
    comments.select {|comment| comment[:created_at] > two_weeks_ago}
  end

  def recent_clones_for_repo(exact_repo_name)
    personal_client
    self.client.clones(exact_repo_name, per: "week")
  end

  def recent_views_for_repo(exact_repo_name)
    personal_client
    self.client.views(exact_repo_name, per: "week")
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