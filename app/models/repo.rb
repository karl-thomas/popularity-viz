class Repo

  attr_accessor :repo

  def initialize(repo)
    @repo = repo
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
  
end