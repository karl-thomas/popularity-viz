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

  def pull_requests
    personal_client
    all_pulls = client.pull_requests(id, state: 'all', since: two_weeks_ago)
    PullRequests.new(all_pulls)
  end

  def recent_pull_requests
    pull_requests.recent_pulls
  end

  def collaborators
    personal_client
    client.collaborators(full_name).pluck(:login)
  end

  def recent?
    updated_at > two_weeks_ago || pushed_at > two_weeks_ago
  end

  def recent_commits
    application_client
    api_response = client.commits(full_name, author: user, since: two_weeks_ago)
    Commits.new(api_response)
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

  def total_counts_by_date
    commits = recent_commits.count_per_day
    pulls = recent_pull_requests.date_grouped_data
    traffic = traffic_data.date_grouped_data
    pulls
      .merge(commits) {|date,pulls,commits,| commits.merge(pulls) }
      .merge(traffic) {|date, data, traffic| data.merge(traffic)  }
  end
  
  def dependent_repo_data
    { 
      counts_by_date: total_counts_by_date,
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

    def date_grouped_data
      count_of_views_per_day.merge(count_of_clones_per_day) {|date, views, clones| views.merge(clones)}
    end

    def recent_clones
      media_type = "application/vnd.github.spiderman-preview"
      personal_client.clones(repo.full_name, per: "week", accept: media_type)
    end

    def count_of_clones_per_day
      recent_clones[:clones].map {|view| [view[:timestamp].to_date.to_s, {clones: view[:count]}]}.to_h
    end

    def recent_views
      media_type = "application/vnd.github.spiderman-preview"      
      @recent_views ||= personal_client.views(repo.full_name, per: "day", accept: media_type)
    end

    def count_of_views_per_day
      recent_views[:views].map {|view| [view[:timestamp].to_date.to_s, {unique_views: view[:uniques]}]}.to_h
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

  class PullRequests
    attr_accessor :pulls
    def initialize(pulls = [])
      if !pulls.blank?
        @pulls = create_pulls(pulls)
        @since = 2.weeks.ago.iso8601
      end
    end

    def oauth_client
      @client  = Octokit::Client.new \
        :access_token    => ENV['GITHUB_TOKEN']
      @client.auto_paginate = true  
      @client
    end
   
    def comments
      oauth_client.issues_comments(pulls[0].repo, since: @since).select {|c| c.author_association == "OWNER"}
    end

    def comments_by_date
      comments.group_by { |comment| comment.created_at.to_date.to_s}
    end

    def count_of_comments_by_date
      comments_by_date.map { |date, comments| [date, {pr_comments: comments.count} ]}.to_h
    end

    def create_pulls(pulls)
      pulls.map {|pull| Pull.new( pull, oauth_client)}
    end

    def date_grouped_data
      count_for_closed
        .merge(count_for_created_at) {|date, closed, created| closed.merge(created) }
        .merge(count_of_comments_by_date) {|date, pulls, comments| pulls.merge(comments) }
    end

    def recent_pulls
      @pulls = pulls.select {|pr| pr.recently_created || pr.recently_closed }
      self
    end

    def closed_pulls
      pulls.select &:closed?
    end

    def grouped_per_closed
      closed_pulls.group_by {|pull| pull.closed_at.to_date.to_s}
    end

    def count_for_closed
       grouped_per_closed.map {|date, pulls| [date, {closed_pull_request: pulls.count}] }.to_h
    end

    def grouped_per_created_at
      pulls.group_by {|pull| pull.created_at.to_date.to_s}
    end

    def count_for_created_at
      grouped_per_created_at.map {|date, pulls| [date, {opened_pull_request: pulls.count}] }.to_h
    end

    class Pull  
      attr_reader :repo, :number, :state, :title, :body, :created_at, :closed_at
      def initialize(pull, client)
        if !pull.blank? && !client.nil?
          @repo = pull.head.repo.full_name
          @number  = pull.number
          @state = pull.state
          @title = pull.title
          @body = pull.body
          @created_at = pull.created_at
          @closed_at = pull.closed_at
          @client = client
        end
      end

      def closed?
        state == "closed"
      end

      def recently_created
        created_at > 2.weeks.ago
      end

      def recently_closed
        closed_at > 2.weeks.ago
      end
    end
  end

  class Commits
    attr_reader :commits
    def initialize(commits)
      @commits = sanitize_commits(commits)
    end

    def count
      commits.count
    end

    def first
      commits[0]
    end

    def messages
      commits.map {|commit| commit[:message] }
    end

    def recent_commit_time_ranges
      recent_commit_dates.map do |day, commits|
        commits.map do |commit| 
          commit[:date]
        end
      end
      .delete_if { |dates| dates.count < 2 }
    end

    def group_per_day
      commits.group_by { |commit| commit[:date] }
    end

    def count_per_day
      group_per_day.map {|date, commits| [ date, {commits: commits.count } ] }.to_h
    end

    private
    def sanitize_commits(commits)
      commits.map do |c| 
        {
          message: c.commit.message, 
          author: c.author.login, 
          date: c.commit.author.date.to_date.to_s
        }
      end
    end
  end
end




