class SongService
  def self.find(id)
    db_connection do |db|
      result = db.exec_params(
        'SELECT * FROM songs WHERE id = $1 LIMIT 1',
        [id]
      )

      return nil unless result.any?

      Song.new(result.first)
    end
  end

  def self.count_by_artist(artist_id)
    db_connection do |db|
      result = db.exec_params(
        'SELECT COUNT(*) AS total FROM songs WHERE artist_id = $1',
        [artist_id]
      )
      result.first['total'].to_i
    end
  end

  def self.by_artist(artist_id, limit: 10, offset: 0)
    db_connection do |db|
      result = db.exec_params(
        'SELECT * FROM songs WHERE artist_id = $1 ORDER BY id DESC LIMIT $2 OFFSET $3',
        [artist_id, limit, offset]
      )

      result.map { |row| Song.new(row) }
    end
  end

  def self.create(params)
    query = <<-SQL
      INSERT INTO songs (artist_id, title, album_name, genre, created_by)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    SQL

    db_connection do |db|
      result = db.exec_params(query, [
                                params['artist_id'],
                                params['title'],
                                params['album_name'],
                                params['genre'],
                                params['created_by']
                              ])

      Song.new(result.first)
    end
  end

  def self.update(id, params)
    query = <<-SQL
      UPDATE songs
      SET title = $1,
          album_name = $2,
          genre = $3,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $4
      RETURNING *
    SQL

    db_connection do |db|
      result = db.exec_params(query, [
                                params['title'],
                                params['album_name'],
                                params['genre'],
                                id
                              ])

      return nil unless result.any?

      Song.new(result.first)
    end
  end

  def self.delete(id)
    db_connection do |db|
      db.exec_params(
        'DELETE FROM songs WHERE id = $1',
        [id]
      )
    end
  end

  def self.artist_id_for(song_id)
    db_connection do |db|
      result = db.exec_params(
        'SELECT artist_id FROM songs WHERE id = $1',
        [song_id]
      )
      return nil unless result.any?

      result.first['artist_id']
    end
  end
end
