class GithubAdapter
  include HTTParty
  base_uri 'https://api.github.com'

  attr_reader :user, :token

  def initialize(user, oauth_token)
    @user = user 
    @token = oauth_token
  end

  def request_all_info
    options = {Authorization: "token #{ENV['GITHUB_TOKEN']}"}
    self.class.get("/users/#{self.user}", options).parsed_response
  end 
end