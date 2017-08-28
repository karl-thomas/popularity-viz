class SpotifyAdapter
  attr_reader :user, :two_weeks_ago
  IMPORTANT_FEATURES = ["acousticness", "danceability", "duration_ms", "energy", "instrumentalness", "speechiness", "tempo", "valence"]
  
  def initialize
    RSpotify.authenticate(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"] )
    @user = ENV['SPOTIFY_USERNAME']
    @two_weeks_ago = 2.weeks.ago.strftime("%Y-%m-%d")
  end

  def profile 
    @profile ||= RSpotify::User.find(self.user)
  end

  def aggregate_data
    recent_tracks = find_tracks(recently_added_track_ids)
    averages = average_audio_features(recent_tracks)
    {
      recent_playlists: recent_playlists.count,
      recently_added_tracks: recent_tracks.count,
      most_occuring_feature: most_occuring_feature(averages),
      average_energy: averages["average_energy"]
    }
  end

  def recent_saved_tracks
    recent_tracks(self.user)
  end

  def owned_playlists_short
    self.profile.playlists.select { |playlist| playlist.owner.id == self.user }
  end

  # for some reason you cant see track info from user.playlists, so you have to go find the playlists individually. 
  def playlist_ids(playlists)
    playlists.map { |playlist| playlist.id }
  end

  # access full playlist info
  def full_playlist(id)
    RSpotify::Playlist.find(self.user, id)
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

  def recently_added_track_ids
    recent_playlists.flat_map {|playlist| recent_tracks(playlist) }
  end

  def recent_tracks(entity)
    entity.tracks_added_at.keys.select {|key| entity.tracks_added_at[key] > two_weeks_ago}
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
    @sum_of_audio_features ||= track_objs.reduce(Hash.new(0)) do |aggregate, track|
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
end