class LinkedinAdapter
  include HTTParty
  base_uri 'https://api.linkedin.com'

  def initialize
    @auth {"Authorization: Bearer #{ENV['LINKEDIN_ACCESS_TOKEN']}"}
  end

  def example_quest
    
  end
end
