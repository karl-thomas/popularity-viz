class TwitterAdapter
  include HTTParty
  base_uri "https://api.twitter.com"

  def initialize
    @user = ENV['TWITTER_USER']
    @headers = {Authorization: "Bearer #{ENV['TWITTER_TOKEN']}"}
  end

  def profile
    p @headers
    p self.class.get("/1.1/users/lookup.json#{@user}", headers: @headers)
  end
end