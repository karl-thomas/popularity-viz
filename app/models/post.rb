class Post
  include TwitterCalcs
  
  include Mongoid::Document
  field :spotify_record, type: Hash
  field :github_record, type: Hash
  field :twitter_record, type: Hash


  before_save :inspect_old_data, :assign_total_differences
  
  attr_accessor :differences
end