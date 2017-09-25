class Post
  include TwitterCalcs

  include Mongoid::Document
  field :spotify_record, type: Hash
  field :github_record, type: Hash
  field :twitter_record, type: Hash
  field :total_interactions, type: Integer
  field :insights, type: Hash

  attr_accessor :differences
  
  before_create :inspect_old_data
  # when add_total_interactions gets before_create it does not add them up properly, after create, it does....
  after_create :add_total_interactions
  
  # this is to give javascript something easy to read and follow some linting rules
  def to_json
    json_post = self.as_json
    json_post['id'] = json_post['_id'].to_s 
    json_post
  end

  def add_total_interactions
    github_keys = self.github_record.select { |k,v| k.to_s.include?('recent')}
    github_keys[:most_recent_project] = 0  # this in a non-countable value
    spotify_keys = self.spotify_record.select { |k,v| k.to_s.include?('recent')}
    twitter_keys = self.twitter_record.select { |k,v| k.to_s.include?('recent')}

    # merge them all together and add them. 
    total = github_keys.merge(twitter_keys).merge(spotify_keys).values.reduce(:+)
    self.total_interactions = total
    self.save
  end
end