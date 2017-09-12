class SpotifyRecord 
  def set_recent_saved_albums
    old_record = SpotifyRecord.last || nil
    return nil if old_record.nil?
    new_albums = self.saved_albums - old_record.saved_albums 
    self.recent_saved_albums = new_albums
  end
end
