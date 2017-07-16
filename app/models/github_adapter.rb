class GithubAdapter
  include HTTParty
  base_uri 'https://api.github.com'

  attr_reader :user

  def initialize(user, oauth_token)
    @user = user 
    @options = {Authorization: "token #{oauth_token}"}
  end

  def request_all_info
    self.class.get("/users/#{self.user}", @options).parsed_response
  end 

  def repos
    self.class.get("/users/#{self.user}/repos", @options).parsed_response
  end

  def all_repo_names
    self.repos.map {|repo| repo["name"]}
  end

  def all_commits
    self.all_repo_names
  end

  def commits_for_repo(repo)
    self.class.get("/repos/#{self.user}/#{repo}", @options).parsed_response
  end
end
