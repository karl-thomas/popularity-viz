class SpotifyAdapter
  attr_reader :user, :username, :profile, :two_weeks_ago
  IMPORTANT_FEATURES = ["acousticness", "danceability", "duration_ms", "energy", "instrumentalness", "speechiness", "tempo", "valence"]
  
  def initialize
    @two_weeks_ago = 2.weeks.ago.strftime("%Y-%m-%d")
    @username = ENV['SPOTIFY_USERNAME']

    RSpotify.authenticate(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])
    
    load_profile
    load_user_auth
    refresh_token
  end

  def aggregate_data
    tracks = all_recent_tracks
    track_objs = find_tracks(tracks)
    averages = average_audio_features(track_objs)
    {
      recent_playlists: recent_playlists.count,
      recently_added_tracks: tracks.count,
      most_occuring_feature: most_occuring_feature(averages),
      average_energy: averages["average_energy"]
    }
  end

  def recently_played
    RSpotify.resolve_auth_request(self.username, 'me/player/recently-played?limit=30'
  end

  def all_recent_tracks
    pl_tracks = recently_added_track_ids
    tracks = pl_tracks.concat(recent_saved_tracks)
  end

  def recent_top_tracks
    self.user.top_tracks(time_range: 'short_term')
  end

  def recent_top_artists
    self.user.top_tracks(time_range: 'short_term')
  end
  
  def recent_saved_tracks
    self.user.saved_tracks # this populates tracks added at
    write_user
    recent_tracks(self.user.tracks_added_at)
  end
  
  def most_recommended_recommendation(track_ids)
    RSpotify::Recommendations.generate(limit: 1, seed_tracks: track_ids)
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
    RSpotify::Track.find(array_of_ids)
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
    @user = RSpotify::User.new(user_preload)
  end

  def write_user
    File.write("./user.yml", self.user.to_hash.to_yaml)
  end

  def reduce_important_features(aggregate, track)
    IMPORTANT_FEATURES.each do |feature|
      value = track.audio_features.instance_variable_get("@#{feature}")
      aggregate["average_#{feature}"] += value
    end 
  end

  def skim_for_countable_averages(averages)
    countables = ["average_acousticness", "average_danceability", "average_energy", "average_instrumentalness", "average_speechiness"]
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