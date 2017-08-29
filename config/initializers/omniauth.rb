require 'rspotify/oauth'

Rails.application.config.middleware.use OmniAuth::Builder do
  p "heyo im in the middle"
  provider :spotify, ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"], scope: 'user-read-email playlist-modify-public user-library-read user-library-modify'
end