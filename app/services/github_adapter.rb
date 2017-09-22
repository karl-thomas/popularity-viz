class GithubAdapter
  attr_reader :user, :client

  def initialize
    application_client
    @user = ENV['GITHUB_USERNAME']
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

  def two_weeks_ago
    2.weeks.ago.strftime("%Y-%m-%d")
  end

  def profile
    personal_client
    @profile ||= self.client.user(self.user)
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
      starred_repos: self.starred_repos.count, # the recent calc needs be done DB side
      recent_projects: self.recent_updated_repos(owned_repos).count,
      recent_gists: self.recent_gists.count,
      recently_starred_gists: self.recent_starred_gists.count
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
    api_response = self.client.repos( self.user, affiliation: "owner" )
    @owned_repos = convert_to_repos(api_response)
  end

  def collaborated_repos
    return @collaborated_repos if @collaborated_repos
    application_client
    api_response = self.client.repos( self.user, affiliation: "collaborator" )
    @collabor = convert_to_repos(api_response)
  end

  def organizations_repos
    return @organizations_repos if @organizations_repos
    application_client
    api_response = self.client.repos( self.user, affiliation: "organization_member" )
    @organizations_repos = convert_to_repos(api_response)
  end

  def starred_repos
    application_client
    api_response = self.client.starred(self.user)
    @starred_repos ||= convert_to_repos(api_response)
  end

  def convert_to_repos(sawyer_resources)
    sawyer_resources.map { |resource| Repo.new(resource)}
  end

  def find_repo(id)
    personal_client
    api_response = self.client.repository(id)
    Repo.new(api_response)
  end

  def recent_updated_repos(repos)
    repos.select { |repo| repo.recent? }
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
  # this data is for only recently updated repos
  def collect_repo_data
    recent_repos = self.recent_updated_repos(collaborated_repos)
    # @var ||= for repeat method calls
    @recent_repo_data ||= recent_repos.map {|repo| repo.dependent_repo_data}
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
  # this data is for all owned repos by the authorized user.
  def collect_traffic_data(repos)
    # @var ||= for repeat method calls
    @traffic_data ||= repos.map {|repo| repo.traffic_data }
  end

  def most_viewed_repo(repos, traffic_data = collect_traffic_data(repos))
    # this uses the enumerator returned by each_with_index and gives it to max_by 
    # so that it may easily find the traffic data for that repo and sum it together
    repos.each_with_index.max_by do |repo, index|
      traffic_data[index][:recent_clones] + 
      traffic_data[index][:recent_views] + 
      traffic_data[index][:recent_stargazers]
    end
  end

  def reduced_traffic_data
    repos = self.owned_repos 
    starting_data = collect_traffic_data(repos)
    hottest_repo = most_viewed_repo(repos, starting_data)

    # melt all the traffic data of all repos into something digesable
    reduced_data = starting_data.reduce(Hash.new(0)) do |aggregate, pairs|
      pairs.each do |key, value|
        reduce_uniques(aggregate, key, value)
        reduce_traffic_keys(aggregate, key, value)
      end
      aggregate
    end
    # add the most viewed repo to the data
    reduced_data.tap {|data| data[:most_viewed_repo] = hottest_repo}
  end


  private

    def traffic_data_sift(traffic_data, id)
      traffic_data.find {|pairs| pairs[:repo_id] == id}
    end

    def sum_of_traffic(sifted_traffic)
      sifted_traffic[:recent_clones] + sifted_traffic[:recent_views] + sifted_traffic[:recent_stargazers]
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

    def truncate_most_used_lang(reduced_data)
      reduced_data[:most_used_lang] = reduced_data[:most_used_lang][0]
      reduced_data
    end

    def choose_hottest_language(aggregate, key, lang_array)

      if key == :most_used_lang
        if aggregate[key] == 0
          aggregate[:most_used_lang] = lang_array
        else
          if aggregate[key][1] < lang_array[1]
            aggregate[:most_used_lang] = lang_array
          end
        end
      end
    end
end