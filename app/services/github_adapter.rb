require 'pry'
require 'octokit'

class GithubAdapter
  attr_reader :user, :client, :two_weeks_ago

  def initialize
    application_client
    @user = ENV['GITHUB_USERNAME'] 
    @two_weeks_ago = 2.weeks.ago.strftime("%Y-%m-%d")
  end

  def profile
    @profile ||= self.client.user(self.user)
  end 

  def aggregrate_data_record
   profile_and_repos =  profile_data.merge(reduced_repo_data)
   profile_and_repos.merge(reduced_traffic_data)
  end

  def profile_data
    {
      username: profile.login,
      repos: total_repos,
      gists: total_gists,
      followers: profile.followers,
      following: profile.following,
      starred_repos: self.starred_repos.count, # the recent calc needs be done DB side
      recent_projects: self.recent_updated_repos(owned_repos).count,
      recent_gists: self.recent_gists.count,
      recently_starred_gists: self.recent_starred_gists.count
    }
  end

  def total_gists
    application_client
    return profile.public_gists if profile.private_gists.nil?
    profile.public_gists + profile.private_gists
  end

  def total_repos
    application_client
    return profile.public_repos if profile.total_private_repos.nil?
    profile.public_repos + profile.total_private_repos
  end

  # repo collections 
  def owned_repos
    application_client
    self.client.repos( self.user, affiliation: "owner" )
  end

  def collaborated_repos
    application_client
    self.client.repos( self.user, affiliation: "collaborator" )
  end

  def organizations_repos
    application_client
    self.client.repos( self.user, affiliation: "organization_member" )
  end

  def recent_updated_repos(repos)
    repos.select { |repo| repo[:pushed_at] > two_weeks_ago }
  end

  def starred_repos
    application_client
    self.client.starred(self.user)
  end

  # gists
  def recent_gists
    application_client
    self.client.gists( self.user, since: two_weeks_ago )
  end

  def recent_starred_gists
    personal_client
    self.client.starred_gists( since: two_weeks_ago )
  end

  # repo behaviour, returns recent info, these things should be in a repo class. 
  def repo_data(repo)
    { 
      repo: repo,
      recent_commits: recent_commits(repo[:full_name]).count,
      recent_comments: recent_commit_comments(repo[:full_name]).count,
      recent_deployments: recent_deployments(repo[:full_name]).count,
      branches: branches(repo[:full_name]).count
      languages: languages(repo)
    }
  end

  def collect_repo_data
    recent_repos = self.recent_updated_repos(collaborated_repos)
    recent_repos.map {|repo| repo_data(repo)}
  end

  def reduced_repo_data
    repositories = collect_repo_data
    repositories.reduce(Hash.new(0)) do |aggregate, pairs|

      choose_recent_project(repositories, aggregate, pairs)
      pairs.each do |key, value|
        reduce_repo_keys(aggregate, key, value)
      end
      aggregate
    end
  end

  def recent_commits(repo_name)
    application_client
    self.client.commits_since(repo_name, two_weeks_ago, author: self.user)
  end

  def all_commit_comments(repo_name)
    application_client
    self.client.list_commit_comments(repo_name)
  end

  def recent_commit_comments(repo_name)
    application_client
    comments = all_commit_comments(repo_name)
    return [] if comments.empty?
    comments.select { |comment| comment[:created_at] > two_weeks_ago }
  end

  def stargazers(repo_name)
    self.client.stargazers(repo_name, accept: 'application/vnd.github.v3.star+json', auto_traversal: true)
  end

  def recent_stargazers(repo_name)
    self.stargazers(repo_name).select { |stargazer| stargazer[:starred_at] > two_weeks_ago}
  end

  def deployments(repo_name)
    application_client
    self.client.deployments(repo_name)
  end

  def recent_deployments(repo_name)
    application_client
    all_deployments = deployments(repo_name)
    return [] if all_deployments.empty?
    all_deployments.select { |deployments| deployments[:created_at] > two_weeks_ago }
  end

  def branches(repo_name)
    self.client.branches(repo_name)
  end

  def languages(repo_name)
    self.client.languages(repo_name)
  end


  # repo traffic, for all owned repos --------------
  def traffic_data(repo)
    recent_views = recent_views_for_repo(repo.full_name)
    {
      repo_id: repo.id,
      recent_views: recent_views[:count],
      recent_clones: recent_clones_for_repo(repo.full_name)[:count],
      unique_views: recent_views[:uniques],
      recent_stargazers: recent_stargazers(repo.full_name).count,
      watchers: repo.watchers_count
    }  
  end

  def collect_traffic_data
    self.owned_repos.map {|repo| traffic_data(repo) }
  end

  def reduced_traffic_data
    starting_data = collect_traffic_data

    starting_data.reduce(Hash.new(0)) do |aggregate, pairs|
      pairs.each do |key, value|
        choose_hottest_repo(starting_data, aggregate, key, value)
        reduce_uniques(aggregate, key, value)
        reduce_traffic_keys(aggregate, key, value)
      end
      aggregate
    end
  end

  def recent_clones_for_repo(repo_name)
    personal_client
    self.client.clones(repo_name, per: "week")
  end

  def recent_views_for_repo(repo_name)
    personal_client
    self.client.views(repo_name, per: "week")
  end


  private
    def application_client
      if !self.client || self.client.client_id.nil?
        @client  = Octokit::Client.new \
          :client_id     => ENV['GITHUB_CLIENT_ID'],
          :client_secret => ENV['GITHUB_CLIENT_SECRET']
      end  
      self.client.auto_paginate = true  
    end

    def personal_client
      if !self.client || self.client.login.nil?
        @client = Octokit::Client.new \
          :login => ENV['GITHUB_USERNAME'],
          :password => ENV['GITHUB_PASSWORD']
      end
      self.client.auto_paginate = true 
    end

    def choose_hottest_repo(starting_data, aggregate, key, id )
      if key == :repo_id
        aggregate[:hottest_repo] = id if aggregate[:hottest_repo] == 0

        new_repo = traffic_data_sift(starting_data, id)  
        tracked_repo = traffic_data_sift(starting_data, aggregate[:hottest_repo])

        if sum_of_traffic(new_repo) > sum_of_traffic(tracked_repo)
          aggregate[:hottest_repo] = new_repo[:repo_id]
        end
      end
    end

    def traffic_data_sift(traffic_data, id)
      traffic_data.find {|pairs| pairs[:repo_id] == id}
    end

    def sum_of_traffic(sifted_traffic)
      sifted_traffic[:recent_clones] + sifted_traffic[:recent_views]
    end

    def reduce_uniques(aggregate, key, views)
      if key == :unique_views
        aggregate[key] = 1 if aggregate[key] == 0 || aggregate[key] == nil
        aggregate[key] += views - 1 if views > 1
        aggregate
      end
    end


    def reduce_traffic_keys(aggregate, key, value) 
      if simple_traffic_reducers.include?(key)
        aggregate[key] += value
      end
    end


    def simple_traffic_reducers
      [:recent_clones, :recent_views, :recent_stargazers, :watchers]
    end

    def reduce_repo_keys(aggregate, key, value) 
      if simple_repo_reducers.include?(key)
        aggregate[key] += value
      end
    end

    def simple_repo_reducers
      [:recent_comments, :recent_deployments, :recent_commits, :branches]
    end

    def choose_recent_project(collected_repositories, aggregate, pairs)
      tracked_repo = sift_repo_data(collected_repositories, aggregate[:most_recent_project])
      new_repo = sift_repo_data(collected_repositories, pairs[:repo].id)

      if aggregate[:most_recent_project] == 0 
        aggregate[:most_recent_project] = pairs[:repo].id 
      elsif tracked_repo[:repo].pushed_at < new_repo[:repo].pushed_at
        aggregate[:most_recent_project] = pairs[:repo].id
      end
    end

    def sift_repo_data(collected_repositories, id)
      collected_repositories.find {|repo| repo[:repo].id == id}
    end
end