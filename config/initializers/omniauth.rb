require 'rspotify/oauth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"], scope: 'user-read-email playlist-read-private user-library-read playlist-read-collaborative user-follow-read user-top-read user-read-currently-playing user-read-recently-played'
end