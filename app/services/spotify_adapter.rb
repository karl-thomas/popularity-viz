class SpotifyAdapter
  
  attr_reader :user, :username, :profile, :two_weeks_ago

  IMPORTANT_FEATURES = ["acousticness", "danceability", "duration_ms", "energy", "instrumentalness", "speechiness", "tempo", "valence"]
  BORING_GENRES = ['rock', 'metal', 'pop', 'garage rock', 'pop rock', 'hip hop', 'indie punk', 'indie rock', 'indie r&b', 'indie fol_k', 'rap', 'underground hip hop', 'new rave', 'modern rock', 'alternative hip hop', 'alternative rock', 'bass music', 'edm', 'alt-indie rock', 'indie garage rock']
  def initialize
    @two_weeks_ago = 2.weeks.ago.strftime("%Y-%m-%d")
    @username = ENV['SPOTIFY_USERNAME']

    RSpotify.authenticate(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])
    
    load_profile
    load_user_auth
    refresh_token
  end
  
  def aggregate_data_record
    tracks = all_recent_tracks
    track_objs = find_tracks(tracks)
    averages = average_audio_features(track_objs)
    recommendation = most_recommended_recommendation(tracks)
    track_hashes = recently_played
    recent_singers = artists(track_hashes)
    # artists = recent_top_artists ===== spotify currently not returning artists, code is valid on my end
    genres = recent_genres(recent_singers)
    fun_genres = filter_boring_genres(genres)
    
    @data_record = {
      playlists: user.playlists.count,
      recent_playlists: recent_playlists.count,
      recently_added_tracks: tracks.count,
      most_occuring_feature: most_occuring_feature(averages),
      average_energy: averages["average_energy"],
      # this is currently removed from the spotify api, but is still valid on my end.
      # top_track: { track: top_track.name, artist: top_track.artists[0].name },
      recent_genres: genres.count,
      interesting_genre: fun_genres.sample,
      saved_albums: saved_albums,
      recommended_track: recommendation
    }
  end

  def recently_played
    @recently_played ||= RSpotify.resolve_auth_request(self.username, "me/player/recently-played?limit=50")
  end

  # expects tracks to be a hash, because recently_played is broke in the gem
  def artists(tracks)
    ids = tracks['items'].flat_map do |info| 
      info['track']['album']['artists'].pluck('id')
    end
    uniq_ids = ids.uniq
    # returns artists
    RSpotify::Artist.find(uniq_ids)
  end

  def get_songs_after date
    date = date.to_i
    RSpotify.resolve_auth_request(self.username, "me/player/recently-played?after=#{date}&limit=50")
  end

  def get_songs_before date
    date = date.to_i
    RSpotify.resolve_auth_request(self.username, "me/player/recently-played?before=#{date}&limit=50")
  end

  def all_recent_tracks
    pl_tracks = recently_added_track_ids
    tracks = pl_tracks.concat(recent_saved_tracks)
  end

  def saved_albums
    self.user.saved_albums.count
  end

  def top_track
    self.user.top_tracks(time_range: 'short_term')[0]
  end

  def recent_top_artists
    self.user.top_artists(time_range: 'short_term')
  end
  
  def recent_genres(artists)
    artists.flat_map {|a| a.genres }.sort.uniq
  end

  def filter_boring_genres(genres)
    genres.select {|genre| !BORING_GENRES.include?(genre)}
  end

  def recent_saved_tracks
    self.user.saved_tracks # this populates tracks added at
    recent_tracks(self.user.tracks_added_at)
  end
  

  def most_recommended_recommendation(track_ids)
    # only accepts 5 tracks
    track_ids = track_ids[0..4]
    api_result = RSpotify::Recommendations.generate(limit: 1, seed_tracks: track_ids)
    # actually access the pnly track in the results.
    recommendation = api_result.tracks.first
    
    {
      track: recommendation.name,
      artist: recommendation.artists.first.name,
      genres: recommendation.artists.first.genres[0..3]
    }
  end

  def owned_playlists_short
    self.profile.playlists.select { |playlist| playlist.owner.id == self.username }
  end

  # for some reason you cant see track info from user.playlists, so you have to go find the playlists individually. 
  def playlist_ids(playlists)
    playlists.map { |playlist| playlist.id }
  end

  # access full playlist info
  def full_playlist(id)
    RSpotify::Playlist.find(self.username, id)
  end

  def owned_playlists_full
    incomplete_playlists = self.owned_playlists_short 
    array_of_ids = playlist_ids(incomplete_playlists)
    array_of_ids.map { |id| self.full_playlist(id) }
  end

  def recent_playlists 
    playlists = self.owned_playlists_full
    @recent_playlists ||= playlists.select { |playlist| recently_updated?(playlist) }
  end

  def recently_updated?(playlist)
    playlist.tracks_added_at.any? { |track, added_at| added_at > two_weeks_ago }
  end


  def recent_tracks(entity)
    if entity.class == Hash
      entity.keys.select {|key| entity[key] > two_weeks_ago}
    else
      entity.tracks_added_at.map { |id, time| id if time > two_weeks_ago }
    end
  end

  def recently_added_track_ids
    recent_playlists.flat_map {|playlist| recent_tracks(playlist) }
  end

  def track(id)
    RSpotify::Track.find(id)
  end

  def find_tracks(array_of_ids)
    ids = array_of_ids.reject {|id| id.nil? }
    RSpotify::Track.find(ids)
  end

  # tracks_objs = find_tracks(recently_added_track_ids)
  def average_audio_features(track_objs)
    if !@averages
      sum = sum_of_audio_features(track_objs)
      @averages ||= sum.tap do |sum|
        sum.each do |key,val|
          sum[key] = (val/10).floor(2)
        end  
      end 
    end
    @averages
  end

  def sum_of_audio_features(track_objs)
    track_objs.reduce(Hash.new(0)) do |aggregate, track|
      reduce_important_features(aggregate, track)
      aggregate
    end
  end

  def most_occuring_feature(averages)
    skimmed = skim_for_countable_averages(averages)
    feature_array = skimmed.max_by {|key, value| value }
    feature_array[0].partition("_")[2]
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
  def reduce_important_features(aggregate, track)
    features = handle_audio_features(track)
    return nil if features.nil?

    IMPORTANT_FEATURES.each do |feature|
      value = features.send(feature)  
      aggregate["average_#{feature}"] += value unless value.nil?
    end 
  end

  # the rescue is because not all songs will have audio features calculated, which is pretty rare
  def handle_audio_features(track)
    begin
      track.audio_features
    rescue  
      nil
    end
  end

  def skim_for_countable_averages(averages)
    countables = ["average_acousticness", "average_danceability", "average_instrumentalness", "average_speechiness"]
    averages.select { |k,v| countables.include?(k)}
  end
  
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