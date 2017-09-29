# this class is for combining apis in interesting ways
module Insight

  # this will be a random process with hopes of making an interesting title. 
  def set_title
    self.title = "#{self.github_record[:most_used_lang][0]}, #{self.spotify_record[:interesting_genre]}, and the #{self.github_record[:recent_commits]} commits"
    self.save
  end

  def add_total_interactions
    github_keys = self.github_record.select { |k,v| k.to_s.include?('recent')}
    github_keys[:most_recent_project] = 0  # this in a non-countable value
    spotify_keys = self.spotify_record.select { |k,v| k.to_s.include?('recent')}
    twitter_keys = self.twitter_record.select { |k,v| k.to_s.include?('recent')}

    # merge them all together and add them. 
    total = github_keys.merge(twitter_keys).merge(spotify_keys).values.reduce(:+)
    self.total_interactions = total
  end

  def set_insights
    self.insights = {
      focused_song: focused_song_to_s
    }
    self.save
  end

  def focused_song_to_s
    data = focused_song
    if !data || data[0].nil?
        self.github_record[:focused_song] = nil
    else
      self.github_record[:focused_song] = "A song that helped me focus recently was #{data[:track]} by #{data[:artist]}"
    end
  end

  def focused_song
    repo = updated_repos.first 

    repo.recent_commit_time_ranges.map do |range|
      # range.last is the first commit of the day, range.first is the last
      songs = SpotifyAdapter.new.get_songs_after(range.last)["items"]
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
    adapter = GithubAdapter.new
    @repos ||= adapter.recent_updated_repos(adapter.owned_repos)
  end
end