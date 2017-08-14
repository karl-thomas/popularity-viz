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
    api_response = self.client.repos( self.user, affiliation: "owner" )
    convert_to_repos(api_response)
  end

  def collaborated_repos
    application_client
    api_response = self.client.repos( self.user, affiliation: "collaborator" )
    convert_to_repos(api_response)
  end

  def organizations_repos
    application_client
    api_response = self.client.repos( self.user, affiliation: "organization_member" )
    convert_to_repos(api_response)
  end

  def convert_to_repos(sawyer_resources)
    sawyer_resources.map { |resource| Repo.new(resource)}
  end

  def recent_updated_repos(repos)
    repos.select { |repo| repo.recent? }
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
  
  # recent project data --------------------------
  def collect_repo_data
    recent_repos = self.recent_updated_repos(collaborated_repos)
    recent_repos.map {|repo| repo.dependent_repo_data}
  end

  def reduced_repo_data
    repositories = collect_repo_data
    reduced_data = repositories.reduce(Hash.new(0)) do |aggregate, pairs|
      choose_recent_project(repositories, aggregate, pairs)
      pairs.each do |key, value|
        reduce_repo_keys(aggregate, key, value)
        choose_hottest_language(aggregate, key, value)
      end
      aggregate
    end
    truncate_most_used_lang(reduced_data)
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

  private

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

    def truncate_most_used_lang(reduced_data)
      p reduced_data[:most_used_lang]
      reduced_data[:most_used_lang] = reduced_data[:most_used_lang][0]
      reduced_data
    end

    def choose_hottest_language(aggregate, key, lang_hash)

      if key == :languages
        lang = most_used_lang(lang_hash)
        if aggregate[key] == 0
          p lang_hash
          aggregate[:most_used_lang] = lang
        else
          if aggregate[key][1] < lang[1]
            aggregate[:most_used_lang] = lang
          end
        end
      end
    end
end