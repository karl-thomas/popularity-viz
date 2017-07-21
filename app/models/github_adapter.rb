class GithubAdapter
  include HTTParty
  base_uri 'https://api.github.com'

  attr_reader :user

  def initialize
    @user = ENV['GITHUB_USERNAME'] 
    @options = {client_id: ENV['GITHUB_CLIENT_ID'], 
                client_secret: ENV['GITHUB_CLIENT_SECRET']}
    @date_two_weeks_ago = 2.weeks.ago.strftime("%Y-%m-%d")
  end

  def profile
    self.class.get("/users/#{self.user}", query: @options)
  end 

  def all_repos
    self.class.get("/users/#{self.user}/repos", query: @options
  end

  def recent_repos
    #query string for search api
    query_string = "q=pushed:>=#{@date_two_weeks_ago}+user:#{self.user}"

    response = self.class.get("/search/repositories?#{query_string}", query: @options)
    response["items"]
  end

  def all_repo_names(arg_repos)
    arg_repos.map {|repo| repo["name"]}
  end

  def commits_for_repo(repo)
    self.class.get("/repos/#{self.user}/#{repo}/commits", query: @options)
  end

  def all_commits(arg_repos)
    self.all_repo_names(arg_repos).map{ |repo_name| commits_for_repo(repo_name)}
  end

  def all_recent_commits
    recent_repo_commits = all_commits(self.recent_repos).flatten
    
    recent_repo_commits.keep_if do |commit|
      commit["commit"]["author"]["name"] == self.user &&
      commit["commit"]["author"]["date"] >= @date_two_weeks_ago 
    end
  end
  # ==== currently broken, 
  # => id prefer to do it this way, because it's only one request.
  # when passing in the correct header it returns
  # {"cache-control":["no-cache"],"connection":["close"],"content-type":["text/html"]
  # otherwise the header is required.  

  def all_recent_commits
    # set custom header for search commits api, right now its under dev.
    accept_header = {"Accept" => "application/vnd.github.cloak-preview"}

    #query string for search api
    query_string = "q=author-date:>=#{@date_two_weeks_ago}+author:#{self.user}"

    response = self.class.get("/search/commits?#{query_string}", {query: @options, headers: accept_header})
    # response["items"]
  end

end
