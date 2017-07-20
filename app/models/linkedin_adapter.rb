class LinkedinAdapter
  include HTTParty
  base_uri 'https://api.linkedin.com'

  def initialize
    @auth {"Authorization: Bearer #{ENV['LINKEDIN_ACCESS_TOKEN']}"}
    @options = {format: 'json'}
    @user = ENV['LINKEDIN_USER']
  end

  def profile
    self.class.get("/v1/profiles/")
  end
end
