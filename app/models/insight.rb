# this class is for combining apis in interesting ways
module Insight

  # this will be a random process with hopes of making an interesting title. 
  def set_title
    self.title = "#{self.github_record['most_used_lang'][0]}, #{self.spotify_record['interesting_genre']}, and the #{self.github_record['most_recent_project']['name']}"
    self.save
  end

  def add_total_interactions
    spotify_keys = self.spotify_record.select { |k,v| k.to_s.include?('recent')}
    twitter_keys = self.twitter_record.select { |k,v| k.to_s.include?('recent')}

    # merge them all together and add them. 
    total = twitter_keys.merge(spotify_keys).values.reduce(:+) + self.github_record['total_recent_data_count']

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
    nil
    else
    "A song that helped me focus recently was #{data[:track]} by #{data[:artist]}"
    end
  end

  def focused_song
    repo = updated_repos.first 

    repo.recent_commits.recent_commit_time_ranges.map do |range|
      # range.last is the first commit of the day, range.first is the last
      songs = SpotifyAdapter.new.get_songs_after(range.last)["items"]
      range_string = nice_date(range.first)
      if song = songs.find {|song| nice_date(Date::parse(song['played_at'])) == range_string}
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
    @repos ||= adapter.owned_repos.recent_repos
  end

  private 

  def nice_date(date_obj)
    "#{date_obj.day} #{date_obj.month} #{date_obj.year}"
  end
end