class GithubAdapter
  include HTTParty
  base_uri 'https://api.github.com'

  attr_reader :user

  def initialize(user)
    @user = user 
    @options = {client_id: ENV['GITHUB_CLIENT_ID'], 
                client_secret: ENV['GITHUB_CLIENT_SECRET']}
  end

  def request_all_info
    self.class.get("/users/#{self.user}", query: @options).parsed_response
  end 

  def repos
    self.class.get("/users/#{self.user}/repos", query: @options).parsed_response
  end

  def all_repo_names
    self.repos.map {|repo| repo["name"]}
  end

  def commits_for_repo(repo)
    self.class.get("/repos/#{self.user}/#{repo}/commits", query: @options).parsed_response
  end

  def all_commits
    self.all_repo_names.map{|repo| commits_for_repo(repo).count}.reduce(:+)
  end

end
