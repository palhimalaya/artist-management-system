class Song
  attr_accessor :id, :artist_id, :title, :album_name, :genre, :created_by

  def initialize(attrs = {})
    @id         = attrs['id']
    @artist_id  = attrs['artist_id']
    @title      = attrs['title']
    @album_name = attrs['album_name']
    @genre      = attrs['genre']
    @created_by = attrs['created_by']
  end

  def validate
    errors = []
    errors << 'Title required' if blank?(title)
    errors
  end

  private

  def blank?(value)
    value.to_s.strip.empty?
  end
end
