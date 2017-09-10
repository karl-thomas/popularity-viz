class Insight
  #this will be databasified eventually
  attr_reader :spotify_adapter, :github_adapter 

  def initialize(args)
    @github_adapter = args.fetch(:github) 
    @spotify_adapter = args.fetch(:spotify)
  end

  def focused_song
    updated_repos.flat_map do |repo| 
      repo.recent_commit_time_ranges.map do |range|
        songs = spotify_adapter.get_songs_after(range.last)["items"]
        if song = songs.find {|song| song['played_at'] < range.first}
          binding.pry
          song_hash = { track: song['track']['name'], 
                        artist: song['track']['artists'].first['name'],
                        played_at: song['played_at']
                      }
          return song_hash
        end
      end
    end
  end

  def updated_repos
    @repos ||= github_adapter.recent_updated_repos(github_adapter.owned_repos)
  end
end