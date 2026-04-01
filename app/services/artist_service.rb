class ArtistService
  def self.find(id)
    db_connection do |db|
      result = db.exec_params(
        'SELECT a.*, u.first_name AS linked_user_name
         FROM artists a
         LEFT JOIN users u ON a.user_id = u.id
         WHERE a.id = $1 LIMIT 1',
        [id]
      )

      return nil unless result.any?

      Artist.new(result.first)
    end
  end

  def self.count
    db_connection do |db|
      result = db.exec_params('SELECT COUNT(*) AS total FROM artists')
      result.first['total'].to_i
    end
  end

  def self.all(limit: 10, offset: 0)
    db_connection do |db|
      result = db.exec_params(
        'SELECT a.*, u.first_name AS linked_user_name
         FROM artists a
         LEFT JOIN users u ON a.user_id = u.id
         ORDER BY a.id DESC LIMIT $1 OFFSET $2',
        [limit, offset]
      )

      result.map { |row| Artist.new(row) }
    end
  end

  def self.create(params)
    query = <<-SQL
      INSERT INTO artists (name, dob, gender, address, first_release_year, no_of_albums_released, created_by)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    SQL

    db_connection do |db|
      result = db.exec_params(query, [
                                params['name'],
                                params['dob'],
                                params['gender'],
                                params['address'],
                                params['first_release_year'],
                                params['no_of_albums_released'],
                                params['created_by']
                              ])

      Artist.new(result.first)
    end
  end

  def self.update(id, params)
    query = <<-SQL
      UPDATE artists
      SET name = $1,
          dob = $2,
          gender = $3,
          address = $4,
          first_release_year = $5,
          no_of_albums_released = $6,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $7
      RETURNING *
    SQL

    db_connection do |db|
      result = db.exec_params(query, [
                                params['name'],
                                params['dob'],
                                params['gender'],
                                params['address'],
                                params['first_release_year'],
                                params['no_of_albums_released'],
                                id
                              ])

      return nil unless result.any?

      Artist.new(result.first)
    end
  end

  def self.delete(id)
    db_connection do |db|
      db.exec_params(
        'DELETE FROM artists WHERE id = $1',
        [id]
      )
    end
  end

  def self.link_user(artist_id, user_id)
    db_connection do |db|
      db.exec_params(
        'UPDATE artists SET user_id = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 AND (user_id IS NULL OR user_id = $1)',
        [user_id, artist_id]
      )
    end
  end

  def self.unlink_user(artist_id)
    db_connection do |db|
      db.exec_params(
        'UPDATE artists SET user_id = NULL, updated_at = CURRENT_TIMESTAMP WHERE id = $1',
        [artist_id]
      )
    end
  end

  def self.unlinked_artist_users
    db_connection do |db|
      result = db.exec_params(
        'SELECT id, first_name FROM users
         WHERE role = $1
         AND id NOT IN (SELECT user_id FROM artists WHERE user_id IS NOT NULL)
         ORDER BY first_name',
        ['artist']
      )

      result.map { |row| { 'id' => row['id'], 'first_name' => row['first_name'] } }
    end
  end

  def self.linked_user_for(artist_id)
    db_connection do |db|
      result = db.exec_params(
        'SELECT u.id, u.first_name FROM artists a JOIN users u ON a.user_id = u.id WHERE a.id = $1',
        [artist_id]
      )

      return nil unless result.any?

      { 'id' => result.first['id'], 'first_name' => result.first['first_name'] }
    end
  end

  def self.find_by_user_id(user_id)
    db_connection do |db|
      result = db.exec_params(
        'SELECT id FROM artists WHERE user_id = $1 LIMIT 1',
        [user_id]
      )

      return nil unless result.any?

      result.first['id']
    end
  end
end
