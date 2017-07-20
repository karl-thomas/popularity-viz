class LinkedinAdapter
  include HTTParty
  base_uri 'https://api.linkedin.com'

  def initialize
    @auth = {"Authorization: Bearer #{ENV['LINKEDIN_ACCESS_TOKEN']}"}
    @options = {format: 'json'}
    @user = ENV['LINKEDIN_USER']
  end

  def profile
    p self.class.get("/v1/profiles/#{self.user}", headers: @auth, query: @options)
  end
end
