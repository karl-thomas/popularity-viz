class SpotifyAdapter
  class Playlist < SpotifyAdapter
    
    attr_reader :id, :username, :custom
    attr_accessor :id
   
    def initialize(starting_data, custom = false)
      @custom = custom
      super()
      
      if custom
        @tracks = create_tracks(starting_data)
      else
        @id = starting_data
      end
    end

    def create_tracks(track_ids = nil)
      if custom 
        track_ids.map {|date, id| SpotifyAdapter::Track.new(id,date)}
      else
        full.tracks_added_at.map {|id,date| SpotifyAdapter::Track.new(id,date)}
      end
    end

    # you need to call rspotify::playlist#tracks in order for tracks_added_at to update
    def tracks
      full.tracks if !custom
      @tracks ||= create_tracks
    end

    def recent?
      @recent ||= tracks.any? {|track| track.recent? }
    end

    def full
      @full ||= RSpotify::Playlist.find(username, id) 
    end

    def recent_tracks
      tracks
      @recent_tracks = tracks.select { |track| track.recent? }
    end

    def sum_of_audio_features
      tracks.reduce(Hash.new(0)) do |aggregate, track|
        return aggregate if track.audio_features.features.nil?

        track.audio.important_features.each do |feature,value|
          aggregate["average_#{feature}"] += value unless value.nil?
        end

        aggregate
      end
    end

    def average_audio_features
      if !@averages
        sum = sum_of_audio_features
        @averages = sum.tap do |sum|
          sum.each do |key,val|
            sum[key] = (val/10).floor(2)
          end  
        end 
      end
      @averages
    end

    def most_occuring_feature
      skimmed = skim_for_countable_averages
      
      feature_array = skimmed.max_by {|key, value| value }
      
      feature_array[0].partition("_")[2]
    end

    private        
      def skim_for_countable_averages
        countables = ["average_acousticness", "average_danceability", "average_instrumentalness", "average_speechiness"]
        average_audio_features.select { |k,v| countables.include?(k)}
      end
  end
end
