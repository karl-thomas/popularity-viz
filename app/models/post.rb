class Post
  include TwitterCalcs

  include Mongoid::Document
  field :spotify_record, type: Hash
  field :github_record, type: Hash
  field :twitter_record, type: Hash
  field :insights, type: Hash

  attr_accessor :differences
  
  before_save :inspect_old_data, :assign_total_differences
  
  # this is to give javascript something easy to read and follow some linting rules
  def to_json
    json_post = self.as_json
    json_post['id'] = json_post['_id'].to_s 
    json_post
  end
end