class SpotifyAdapter
  autoload :Track, 'spotify_adapter/track'
  autoload :PlaylistCollection, 'spotify_adapter/playlist_collection'
  autoload :Playlist, 'spotify_adapter/playlist'
  
  attr_reader :user, :username, :profile, :two_weeks_ago

  BORING_GENRES = ['rock', 'metal', 'pop', 'garage rock', 'pop rock', 'hip hop', 'indie punk', 'indie rock', 'indie r&b', 'indie fol_k', 'rap', 'underground hip hop', 'new rave', 'modern rock', 'alternative hip hop', 'alternative rock', 'bass music', 'edm', 'alt-indie rock', 'indie garage rock']
  
  def initialize
    @two_weeks_ago = 2.weeks.ago.strftime("%Y-%m-%d")
    @username = ENV['SPOTIFY_USERNAME']
    authenticate
    load_profile
    load_user_auth
    refresh_token
  end
  
  def authenticate
     RSpotify.authenticate(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])
  end

  def aggregate_data_record
    return @data_record if @data_record

    averages = all_recent_tracks.average_audio_features
    most_occuring_feature = all_recent_tracks.most_occuring_feature
    track_hashes = recently_played
    recent_singers = artists(track_hashes)
    # spotify currently not returning artists, its valid/tested/works on my end
    # artists = recent_top_artists
    genres = recent_genres(recent_singers)
    fun_genres = filter_boring_genres(genres)
    
    @data_record = {
      counts_by_date: total_count_data,
      most_occuring_feature: most_occuring_feature,
      average_energy: averages["average_energy"],
      recent_genres: genres.count,
      interesting_genre: fun_genres.sample,
      recommended_track: recommendation
    }
  end


  def recently_played
    @recently_played ||= RSpotify.resolve_auth_request(self.username, "me/player/recently-played?limit=50")["items"]
  end

  # expects tracks to be a hash, because recently_played is broke in the gem
  def artists(tracks)
    ids = tracks.flat_map do |info| 
      info['track']['album']['artists'].pluck('id')
    end
    uniq_ids = ids.uniq
    # returns artists
    RSpotify::Artist.find(uniq_ids)
  end
  

  def recent_genres(artists)
    artists.flat_map {|a| a.genres }.sort.uniq
  end

  def filter_boring_genres(genres)
    genres.select { |genre| !BORING_GENRES.include?(genre) }
  end

  def recommendation
    # only accepts 5 tracks
    track_ids = recently_played.map {|t| t["track"]["id"]}[0..4]
    api_result = RSpotify::Recommendations.generate(limit: 1, seed_tracks: track_ids)
    # actually access the 0nly track in the results.
    recommendation = api_result.tracks.first
    artist = recommendation.artists.first
    {
      track: recommendation.name,
      artist: artist.name,
      genres: artist.genres[0..3]
    }
  end

  def owned_playlists
	  playlists = self.profile.playlists.select { |playlist| playlist.owner.id == self.username }
    PlaylistCollection.new(playlists)
  end

  def total_count_data
    owned_playlists.count_of_tracks_by_date
      .merge(count_of_saved_tracks) {|date, a, s| a.merge(s)}
  end

  def recently_saved_tracks
    # update saved tracks to reuse tracks_added_at
    user.saved_tracks
    user.tracks_added_at.map { |id,date| [date, id] if date > two_weeks_ago }.compact.to_h  
  end

  def count_of_saved_tracks
    groups = group_tracks_by_date(recently_saved_tracks)
    groups.map {|date, tracks| [ date, { saved_tracks: tracks.count }]}.to_h 
  end

  def group_tracks_by_date(track_hashes)
    track_hashes.group_by {|date, id| date.to_date.to_s }
  end

  # merges the tracks off the playlists and "saved" sections of spotify
  # returns a "custom" playlist object.
  def all_recent_tracks
    pl_tracks = owned_playlists.all_recent_tracks.map {|track| [track.added_at,track.id]}.to_h
    tracks = pl_tracks.merge(recently_saved_tracks)
    Playlist.new(tracks, true)
  end

  

private

  def load_profile
    @profile = RSpotify::User.find(ENV['SPOTIFY_USERNAME'])
  end
 
  def load_user_auth
    user_preload = YAML.load_file('./user.yml')
    user_preload["email"] = ENV["SPOOFY_EMAIL"]
    user_preload["credentials"]["token"] = ENV["SPOTIFY_TOKEN"]
    user_preload["credentials"]["refresh_token"] = ENV["SPOTIFY_REFRESH_TOKEN"]

    @user = RSpotify::User.new(user_preload)
  end

  # grab the audio features, for each of the important features add them up as an average

  
  def auth_header
    {
      'Authorization' => "Basic #{ENV['SPOTIFY_BASE']}",
      'Content-Type'  => 'application/json'
    }
  end
  
  def refresh_token
    request_body = {
      grant_type: 'refresh_token',
      refresh_token: self.user.credentials['refresh_token']
    }
    response = RestClient.post('https://accounts.spotify.com/api/token', request_body, auth_header)
    json = JSON.parse(response)
    self.user.credentials['token'] = json['access_token']
  end
  
end

  # not in use
  # def get_songs_after date
  #   date = date.to_i
  #   RSpotify.resolve_auth_request(self.username, "me/player/recently-played?after=#{date}&limit=50")
  # end

  # def get_songs_before date
  #   date = date.to_i
  #   RSpotify.resolve_auth_request(self.username, "me/player/recently-played?before=#{date}&limit=50")
  # end

  # def saved_albums
  #   self.user.saved_albums
  # end

  # def top_track
  #   self.user.top_tracks(time_range: 'short_term')[0]
  # end

  # def recent_top_artists
  #   self.user.top_artists(time_range: 'short_term')
  # end