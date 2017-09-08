class Post
  include Mongoid::Document
  field :spotify_record, type: String
  field :github_record: String
  field :twitter_record, type: String
end