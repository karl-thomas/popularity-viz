class Repo < GithubAdapter
  attr_reader :root, :owner, :id, :full_name, :two_weeks_ago, :watchers_count, :updated_at, :pushed_at, :traffic_data, :user

  def initialize(sawyer_resource = {}) 
    application_client
    @user = ENV['GITHUB_USERNAME']
    @root = sawyer_resource
    @owner = root.owner
    @id = root.id || nil
    @full_name = root.full_name || nil
    @watchers_count = root.watchers_count || nil
    @updated_at = root.updated_at
    @pushed_at = root.pushed_at
    @traffic_data = TrafficData.new( self, application_client, personal_client) 
  end

  def two_weeks_ago
    2.weeks.ago.strftime("%Y-%m-%d")
  end

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


  def recent_commits
    application_client
    client.commits(full_name, author: user, since: two_weeks_ago)
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

  def top_language
    # if there is a top language
    if top_lang = languages.max_by {|lang, bytes| bytes}
      top_lang # return it
    else
      [nil, nil] # still have a top lang format that i can use
    end
  end
  
  # its not important to know everything about stargazers as of right now
  def stargazers
    @stargazers ||= client.stargazers(full_name).pluck(:login)
  end

  def dependent_repo_data
    { 
      repo: self,
      recent_pull_requests: recent_pull_requests.count,
      recent_commits: recent_commits.count,
      recent_comments: recent_commit_comments.count,
      recent_deployments: recent_deployments.count,
      branches: branches.count,
      most_used_lang: top_language
    }
  end

  class TrafficData  
    attr_reader :repo, :application_client, :personal_client, :two_weeks_ago

    def initialize(repo, application_client, personal_client)
      @repo = repo 
      @application_client = application_client
      @personal_client = personal_client
      @two_weeks_ago = 2.weeks.ago.strftime("%Y-%m-%d")
    end

    def stargazers
      application_client.stargazers(repo.full_name, accept: 'application/vnd.github.v3.star+json', auto_traversal: true).pluck(:user).pluck(:login)
    end

    def recent_stargazers
      stargazers.select { |stargazer| stargazer[:starred_at] > two_weeks_ago}
    end

    def recent_clones
      media_type = "application/vnd.github.spiderman-preview"
      personal_client.clones(repo.full_name, per: "week", accept: media_type)
    end

    def recent_views
      media_type = "application/vnd.github.spiderman-preview"      
      @recent_views ||= personal_client.views(repo.full_name, per: "week", accept: media_type)
    end

    def unique_views
      recent_views[:uniques]
    end

    def to_h
      @traffic_data ||= {
        full_name: repo.full_name,
        language: repo.top_language[0], 
        recent: repo.recent?,
        recent_views: recent_views[:count],
        recent_clones: recent_clones[:count],
        unique_views: unique_views,
        recent_stargazers: recent_stargazers.count,
        watchers: repo.watchers_count
      }  
    end

    def sum_of_interactions
      data_set = self.to_h
      # countable values
      data_set[:recent_clones] + 
      data_set[:recent_views] + 
      data_set[:recent_stargazers]
    end    
  end
  
  private
  def group_by_day commit
    commit[:commit][:author][:date].to_date.to_s  
  end
end