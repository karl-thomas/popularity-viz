class Repo < GithubAdapter
  attr_reader :root, :owner, :id, :full_name, :two_weeks_ago, :watchers_count, :updated_at, :pushed_at

  def initialize(sawyer_resource = {}) 
    application_client
    @root = sawyer_resource
    @owner = root.owner
    @id = root.id || nil
    @full_name = root.full_name || nil
    @watchers_count = root.watchers_count || nil
    @updated_at = root.updated_at
    @pushed_at = root.pushed_at
    @two_weeks_ago = 2.weeks.ago.strftime("%Y-%m-%d")
  end

  # -- todo -- Pull requestin,
  def recent_pull_requests
    personal_client
    all_pulls = client.pull_requests(id, state: 'all', since: two_weeks_ago)
    all_pulls.select { |pull| pull[:created_at] > two_weeks_ago }
  end

  def collaborators
    personal_client
    client.collaborators(full_name).pluck(:login)
  end

  def recent?
    updated_at > two_weeks_ago || pushed_at > two_weeks_ago
  end

  def recent_commit_time_ranges
    recent_commit_dates.map do |day, commits|
      commits.map do |commit| 
        commit[:commit][:author][:date]
      end
    end
    .delete_if { |dates| dates.count < 2 }
  end

  def recent_commit_dates
    recent_commits.group_by { |commit| group_by_day(commit) }
  end

  def group_by_day commit
    commit[:commit][:author][:date].to_date.to_s  
  end

  def recent_commits
    application_client
    client.commits_since(full_name, two_weeks_ago, author: user)
  end

  def all_commit_comments
    application_client
    client.list_commit_comments(full_name)
  end

  def recent_commit_comments
    application_client
    comments = all_commit_comments
    return [] if comments.empty?
    comments.select { |comment| comment[:created_at] > two_weeks_ago }
  end

  def deployments
    application_client
    client.deployments(full_name)
  end

  def recent_deployments
    all_deployments = deployments
    return [] if all_deployments.empty?
    all_deployments.select { |deployments| deployments[:created_at] > two_weeks_ago }
  end

  def branches
    application_client
    client.branches(full_name)
  end

  def languages
    application_client
    client.languages(full_name)
  end

  def most_used_lang
    languages.max_by {|lang, bytes| bytes}
  end
  
  def dependent_repo_data
    { 
      repo: self,
      recent_pull_requests: recent_pull_requests.count,
      recent_commits: recent_commits.count,
      recent_comments: recent_commit_comments.count,
      recent_deployments: recent_deployments.count,
      branches: branches.count,
      most_used_lang: most_used_lang
    }
  end

  def stargazers
    application_client
    client.stargazers(full_name, accept: 'application/vnd.github.v3.star+json', auto_traversal: true).pluck(:user).pluck(:login)
  end

  def recent_stargazers
    stargazers.select { |stargazer| stargazer[:starred_at] > two_weeks_ago}
  end

  def recent_clones
    personal_client
    media_type = "application/vnd.github.spiderman-preview"
    client.clones(full_name, per: "week", accept: media_type)
  end

  def recent_views
    personal_client
    media_type = "application/vnd.github.spiderman-preview"      
    client.views(full_name, per: "week", accept: media_type)
  end

  def traffic_data
    views = recent_views
    {
      repo_id: id,
      recent_views: views[:count],
      recent_clones: recent_clones[:count],
      unique_views: views[:uniques],
      recent_stargazers: recent_stargazers.count,
      watchers: watchers_count
    }  
  end
end