class Post < ActiveRecord::Base
  include Insight # ./insight

  attr_accessor :differences
  after_create :set_title

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