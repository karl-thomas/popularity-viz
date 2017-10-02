class Post
  include TwitterCalcs # ./twitter_calcs 
  include Insight # ./insight

  include Mongoid::Document
  include Mongoid::Timestamps
  field :spotify_record, type: Hash
  field :github_record, type: Hash
  field :twitter_record, type: Hash
  field :total_interactions, type: Integer
  field :insights, type: Hash
  field :title, type: String

  attr_accessor :differences
  
  before_create :inspect_old_data, :add_total_interactions
  after_create :set_title, :set_insights 

  def self.cards
    self.all.map(&:card)
  end

  def card
    {
      id: self.id.to_s,
      title: self.title,
      total_interactions: self.total_interactions,
      created_at: self.created_at
    }
  end
  
  # this is to give javascript something easy to read and follow some linting rules
  def to_json
    json_post = self.as_json
    json_post['id'] = json_post['_id'].to_s 
    json_post
  end


end