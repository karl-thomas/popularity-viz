class RepoCollection
  class NoReposError < StandardError; end
  
  SIMPLE_REPO_REDUCERS =[:recent_comments, :recent_deployments, :recent_commits, :recent_pull_requests, :branches]
  SIMPLE_TRAFFIC_REDUCERS = [:recent_clones, :recent_views, :recent_stargazers, :watchers]

  attr_accessor :repos

  def initialize(repos)
    raise NoReposError if repos.nil? || repos.blank?
    @repos = assign_repos(repos)
  end

  def assign_repos(unchecked_repos)
    raise NoReposError.new("Failed to pass in an Array to #{self}") if unchecked_repos.class != Array
    klass = unchecked_repos.first.class 
    if klass != Repo &&  klass == Sawyer::Resource 
      return convert_to_repos(unchecked_repos)
    elsif klass != Repo && klass != Sawyer::Resource 
      raise NoReposError.new("Repos in collection must be type of Repo OR Sawyer::Resource") 
    end
    unchecked_repos
  end

  def convert_to_repos(sawyer_resources)
    sawyer_resources.map {|repo| Repo.new(repo)}
  end

  def count
    self.repos.count
  end
  alias_method  :length, :count

  def [](value)
    begin
      raise TypeError if !value.integer?
    rescue
      raise TypeError
    end
    self.repos[value]
  end

  def first
    self[0]
  end

  def recent_repos
    @recent_repos ||= repos.select { |repo| repo.recent? }
  end 

  def recent_repo_data
    # @var ||= for repeat method calls
    @recent_repo_data ||= recent_repos.map {|repo| repo.dependent_repo_data}
  end

  def most_used_language
    recent_repo_data.pluck(:most_used_lang).max_by do |lang, bytes|
      bytes
    end
  end

  def most_recent_project
    self.repos.max_by { |repo| repo.pushed_at }
  end

  def reduced_repo_data
    reduced_data = recent_repo_data.reduce(Hash.new(0)) do |aggregate, pairs|   
      pairs.each do |key, value|
        reduce_repo_keys(aggregate, key, value)
      end
      aggregate
    end
    # add the most used language to the data. 
    @reduced_data = reduced_data.tap do |data| 
      data[:most_used_lang] = most_used_language
      data[:most_recent_project] = most_recent_project
    end
  end

  # traffic data. 
  def collect_traffic_data
    traffic_data = self.repos.map {|repo| repo.traffic_data.to_h }
  end

  def most_viewed_repo
    found_repo = self.repos.max_by { |repo| repo.traffic_data.sum_of_interactions }
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
    @reduced_traffic_data = reduced_data.tap {|data| data[:most_viewed_repo] = most_viewed_repo}
  end

  private 
    # Unique views need to be handled in a different way than a normal key.
    def reduce_uniques(aggregate, key, views)
      if key == :unique_views
        aggregate[key] = 1 if aggregate[key] == 0 || aggregate[key] == nil
        aggregate[key] += views - 1 if views > 1
        aggregate
      end
    end

    def reduce_traffic_keys(aggregate, key, value) 
      if SIMPLE_TRAFFIC_REDUCERS.include?(key)
        aggregate[key] += value
      end
    end

    def reduce_repo_keys(aggregate, key, value) 
      if SIMPLE_REPO_REDUCERS.include?(key)
        aggregate[key] += value
      end
    end


    def sift_repo_data(id)
      self.repos.find {|repo| repo.id == id}
    end
end