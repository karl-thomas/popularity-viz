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
    return @aggregate_data_record if @aggregate_data_record
    repo_data = traffic_data.merge(dependent_repo_data)
    data_hash = profile_data.merge(repo_data)
    data_hash = total_data_count(data_hash)
    data_hash = total_recent_data_count(data_hash)
    @aggregate_data_record ||= data_hash
  end

  def dependent_repo_data 
    @dependent_repo_data ||= self.collaborated_repos.reduced_repo_data
  end

  def traffic_data
    @traffic_data ||= self.owned_repos.reduced_traffic_data
  end

  def profile_data
    @profile_data ||= {
      username: profile.login,
      repos: total_repos,
      gists: total_gists,
      followers: profile.followers,
      following: profile.following,
      starred_repos: starred_repos.count, # the recent calc needs be done DB side
      recent_projects: owned_repos.recent_repos.count,
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
    @owned_repos = RepoCollection.new(api_response)
  end

  def collaborated_repos
    return @collaborated_repos if @collaborated_repos
    application_client
    api_response = client.repos( user, affiliation: "collaborator" )
    @collabor = RepoCollection.new(api_response)
  end

  def organizations_repos
    return @organizations_repos if @organizations_repos
    application_client
    api_response = client.repos( user, affiliation: "organization_member" )
    @organizations_repos = RepoCollection.new(api_response)
  end

  def starred_repos
    application_client
    api_response = client.starred(user)
    @starred_repos ||= RepoCollection.new(api_response)
  end

  def find_repo(id)
    personal_client
    api_response = client.repository(id)
    Repo.new(api_response)
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
  
  def total_recent_data_count(data_hash)
    klone = data_hash.dup
    # ignore repeat or invalid values
    klone[:most_recent_project] = 0
    count = klone.select{|k,v| k.to_s.include?('recent')}.values.reduce(:+)
    data_hash.tap {|h| h[:total_recent_data_count] = count}
  end

  def total_data_count(data_hash)
    klone = data_hash.dup
    # ignore repeat or invalid values 
    klone[:username] = 0
    klone[:most_recent_project] = 0
    klone[:most_viewed_repo]=0
    klone[:most_used_lang]= 0
    klone[:unique_views] = 0
    klone[:recent_projects] = 0
    count = klone.values.reduce(:+)
    data_hash.tap {|h| h[:total_data_count] = count}
  end
end