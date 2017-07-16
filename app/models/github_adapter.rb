class GithubAdapter
  include HTTParty
  base_uri 'https://api.github.com'

  attr_reader :user

  def initialize(user)
    @user = user 
    @options = {client_id: ENV['GITHUB_CLIENT_ID'], 
                client_secret: ENV['GITHUB_CLIENT_SECRET']}
  end

  def profile
    self.class.get("/users/#{self.user}", query: @options).parsed_response
  end 

  def repos
    self.class.get("/users/#{self.user}/repos", query: @options).parsed_response
  end

  def recent_repos
    filtered_set = self.repos.map {|repo| repo if repo['pushed_at'] > 2.weeks.ago}
    filtered_set.delete_if {|item| item == nil}
  end

  def all_repo_names(arg_repos)
    arg_repos.map {|repo| repo["name"]}
  end

  def commits_for_repo(repo)
    self.class.get("/repos/#{self.user}/#{repo}/commits", query: @options).parsed_response
  end

  def all_commits(arg_repos)
    self.all_repo_names(arg_repos).map{ |repo_name| commits_for_repo(repo_name)}
  end

  def all_recent_commits
    self.all_commits(self.recent_repos).flatten.count
  end

end
