class RepoCollection
  class NoReposError < StandardError; end

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
    @recent_repo_data ||= recent_repos.map { |repo| repo.dependent_repo_data} 
  end

  def most_used_language
    recent_repo_data.pluck(:most_used_lang).max_by do |lang, bytes|
      bytes
    end
  end

  def most_recent_project
    # grab the most recent project, then the date grouped data from it
    repo = self.repos.max_by { |repo| repo.pushed_at }

    { 
      name: repo.full_name.partition("/")[2],
      recent_commits: repo.recent_commits.count,
      counts_by_date: repo.total_counts_by_date
    }
  end

  def reduced_repo_data
    reduced_data = reduce_count_by_date(recent_repo_data) # need to bake down the current data count 
    # assign most used language
    reduced_data[:most_used_lang] = most_used_language
    # assign most viewed repo
    reduced_data[:most_viewed_repo] = most_viewed_repo
    # assign most recent_project
    reduced_data[:most_recent_project] = most_recent_project
    # sort the dates
    order_counts_by_date(reduced_data)
  end

  def reduce_count_by_date(data)
    data.reduce do |aggregate, repo|
      aggregate[:counts_by_date] = 
        aggregate[:counts_by_date].merge(repo[:counts_by_date]) do |date, aggr_hash, new_hash|
            aggr_hash.merge(new_hash) do |key, aggr_value, new_value|
              aggr_value + new_value
            end
          end
      aggregate
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

  private 
    def order_counts_by_date(reduced_data)
      reduced_data[:counts_by_date] = reduced_data[:counts_by_date].sort_by {|date, hash| date }.to_h
      reduced_data[:most_recent_project][:counts_by_date] = reduced_data[:most_recent_project][:counts_by_date].sort_by {|date, hash| date }.to_h
      reduced_data
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