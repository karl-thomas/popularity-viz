# this class is for combining apis in interesting ways
class Insight
  attr_reader :spotify_adapter, :github_adapter 

  def initialize(args)
    @github_adapter = args.fetch(:github) 
    @spotify_adapter = args.fetch(:spotify)
  end

  def total_insights
    {
      focused_song: focused_song_to_s
    }
  end

  def focused_song_to_s
    data = focused_song
    return nil if !data || data[0].nil?
    "A song that helped me focus recently was #{data[:track]} by #{data[:artist]}"
  end

  def focused_song
    repo = updated_repos.first 

    repo.recent_commit_time_ranges.map do |range|
      # range.last is the first commit of the day, range.first is the last
      songs = spotify_adapter.get_songs_after(range.last)["items"]
      if song = songs.find {|song| song['played_at'] < range.first}
        song_hash = { 
              track: song['track']['name'], 
              artist: song['track']['artists'].first['name'],
              played_at: song['played_at']
          }
        return song_hash
      end
    end
  end

  def updated_repos
    @repos ||= github_adapter.recent_updated_repos(github_adapter.owned_repos)
  end
end