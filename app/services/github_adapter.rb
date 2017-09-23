class GithubAdapter
  attr_reader :user, :client

  def initialize
    application_client
    @user = ENV['GITHUB_USERNAME']
  end

  def application_client
    if !client || client.client_id.nil?
      @client  = Octokit::Client.new \
        :client_id     => ENV['GITHUB_CLIENT_ID'],
        :client_secret => ENV['GITHUB_CLIENT_SECRET']
    end  
    client.auto_paginate = true  
    client
  end

  def personal_client
    if !client || client.login.nil?
      @client = Octokit::Client.new \
        :login => ENV['GITHUB_USERNAME'],
        :password => ENV['GITHUB_PASSWORD']
    end
    client.auto_paginate = true 
    client
  end

  def two_weeks_ago
    2.weeks.ago.strftime("%Y-%m-%d")
  end

  def profile
    personal_client
    @profile ||= client.user(user)
  end 

  def aggregate_data_record
   profile_and_repos =  profile_data.merge(reduced_repo_data)
   aggregate_record = profile_and_repos.merge(reduced_traffic_data)
  end

  def profile_data
    {
      username: profile.login,
      repos: total_repos,
      gists: total_gists,
      followers: profile.followers,
      following: profile.following,
      starred_repos: starred_repos.count, # the recent calc needs be done DB side
      recent_projects: recent_updated_repos(owned_repos).count,
      recent_gists: recent_gists.count,
      recently_starred_gists: recent_starred_gists.count
    }
  end

  def total_gists
    return profile.public_gists if profile.private_gists.nil?
    profile.public_gists + profile.private_gists
  end

  def total_repos
    return profile.public_repos if profile.total_private_repos.nil?
    profile.public_repos + profile.total_private_repos
  end

  # repo collections ------------------------------------------
  # guard statements to return instance variable because these may get called a few times
  def owned_repos
    return @owned_repos if @owned_repos
    application_client
    api_response = client.repos( user, affiliation: "owner" )
    @owned_repos = convert_to_repos(api_response)
  end

  def collaborated_repos
    return @collaborated_repos if @collaborated_repos
    application_client
    api_response = client.repos( user, affiliation: "collaborator" )
    @collabor = convert_to_repos(api_response)
  end

  def organizations_repos
    return @organizations_repos if @organizations_repos
    application_client
    api_response = client.repos( user, affiliation: "organization_member" )
    @organizations_repos = convert_to_repos(api_response)
  end

  def starred_repos
    application_client
    api_response = client.starred(user)
    @starred_repos ||= convert_to_repos(api_response)
  end

  def convert_to_repos(sawyer_resources)
    sawyer_resources.map { |resource| Repo.new(resource)}
  end

  def find_repo(id)
    personal_client
    api_response = client.repository(id)
    Repo.new(api_response)
  end

  def recent_updated_repos(repos)
    repos.select { |repo| repo.recent? }
  end


  # gists
  def recent_gists
    application_client
    client.gists( user, since: two_weeks_ago )
  end

  def recent_starred_gists
    personal_client
    client.starred_gists( since: two_weeks_ago )
  end
  
  # recent project data --------------------------
  # this data is for only recently updated repos
  def collect_repo_data
    recent_repos = recent_updated_repos(collaborated_repos)
    # @var ||= for repeat method calls
    @recent_repo_data ||= recent_repos.map {|repo| repo.dependent_repo_data}
  end
  
  def choose_most_used_language(recent_repo_data)
    recent_repo_data.pluck(:most_used_lang).max_by do |lang, bytes|
      bytes
    end
  end

  def reduced_repo_data
    repositories = collect_repo_data
    language = choose_most_used_language(repositories)

    reduced_data = repositories.reduce(Hash.new(0)) do |aggregate, pairs|   
      pairs.each do |key, value|
        choose_recent_project(repositories, aggregate, pairs)
        reduce_repo_keys(aggregate, key, value)
      end
      aggregate
    end
    # add the most used language to the data. 
    reduced_data.tap { |data| data[:most_used_lang] = language }
  end

 
  # repo traffic, for all owned repos --------------
  # this data is for all owned repos by the authorized user.
  def collect_traffic_data
    traffic_data = self.owned_repos.map {|repo| repo.traffic_data.to_h }
  end

  def most_viewed_repo
    found_repo = self.owned_repos.max_by { |repo| repo.traffic_data.sum_of_interactions }
    found_repo.traffic_data.to_h
  end

  def reduced_traffic_data
    starting_data = collect_traffic_data

    # melt all the traffic data of all repos into something digestable
    reduced_data = starting_data.reduce(Hash.new(0)) do |aggregate, pairs|
      pairs.each do |key, value|
        reduce_uniques(aggregate, key, value)
        reduce_traffic_keys(aggregate, key, value)
      end
      aggregate
    end
    # add the most viewed repo to the data
    reduced_data.tap {|data| data[:most_viewed_repo] = most_viewed_repo}
  end


  private
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
      [:recent_comments, :recent_deployments, :recent_commits, :recent_pull_requests, :branches]
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