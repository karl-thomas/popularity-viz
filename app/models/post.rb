class Post
  include Mongoid::Document
  field :spotify_record, type: Hash
  field :github_record, type: Hash
  field :twitter_record, type: Hash
end