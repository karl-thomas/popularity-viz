class Repo < GithubAdapter
  attr_reader :client, :full_name, :two_weeks_ago, :updated_at, :pushed_at

  def initialize(sawyer_resource = {}) 
    application_client
    @id = sawyer_resource.id || nil
    @full_name = sawyer_resource.full_name || nil
    @watchers_count = sawyer_resource.watchers_count || nil
    @updated_at = sawyer_resource.updated_at
    @pushed_at = sawyer_resource.pushed_at
    @two_weeks_ago = 2.weeks.ago.strftime("%Y-%m-%d")
  end

  def recent?
    self.updated_at > two_weeks_ago || self.pushed_at > two_weeks_ago
  end

  def recent_commits
    application_client
    self.client.commits_since(self.full_name, two_weeks_ago, author: self.user)
  end

  def all_commit_comments
    application_client
    self.client.list_commit_comments(self.full_name)
  end

  def recent_commit_comments
    application_client
    comments = all_commit_comments
    return [] if comments.empty?
    comments.select { |comment| comment[:created_at] > two_weeks_ago }
  end

  def stargazers
    application_client
    self.client.stargazers(self.full_name, accept: 'application/vnd.github.v3.star+json', auto_traversal: true)
  end

  def recent_stargazers
    self.stargazers.select { |stargazer| stargazer[:starred_at] > two_weeks_ago}
  end

  def deployments
    application_client
    self.client.deployments(self.full_name)
  end

  def recent_deployments
    all_deployments = deployments
    return [] if all_deployments.empty?
    all_deployments.select { |deployments| deployments[:created_at] > two_weeks_ago }
  end

  def branches
    application_client
    self.client.branches(self.full_name)
  end

  def languages
    application_client
    self.client.languages(self.full_name)
  end

  def most_used_lang
    languages.max_by {|lang, bytes| bytes}
  end
  
  def dependent_repo_data
    { 
      recent_commits: self.recent_commits.count,
      recent_comments: self.recent_commit_comments.count,
      recent_deployments: self.recent_deployments.count,
      branches: self.branches.count,
      languages: self.languages
    }
  end

end