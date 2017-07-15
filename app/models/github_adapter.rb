class GithubAdapter
  include HTTParty
  base_uri 'https://api.github.com'

  def initialize(user, oauth_token)
    # @options waiting for me to decide on token
  end

  def request_all_info
    
  end 
end