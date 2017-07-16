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

  def all_repos
    self.class.get("/users/#{self.user}/repos", query: @options).parsed_response
  end

  def recent_repos
    date = 2.weeks.ago.strftime("%Y-%m-%d")
    query_string = "q=pushed:>=#{date}+user:#{self.user}"
    response = self.class.get("/search/repositories?#{query_string}", query: @options)
    response["items"]
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
    date = 2.weeks.ago.strftime("%Y-%m-%d")
    query_string = "q=author-date:>=#{date}+author:#{self.user}"
    response = self.class.get("/search/commits?#{query_string}", query: @options)
    # response["items"]
  end

end
