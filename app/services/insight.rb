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
        p range.first, range.last
        p songs = spotify_adapter.get_songs_after(range.first)["items"]
        if song = songs.find {|song| song['played_at'] < range.last}
          p "here"
          return song
        end
      end
    end
  end

  def updated_repos
    @repos ||= github_adapter.recent_updated_repos(github_adapter.owned_repos)
  end
end