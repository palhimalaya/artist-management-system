class DashboardController < ApplicationController
  def index(req, res)
    user = authorize(req, res, %w[super_admin artist_manager artist])
    return unless user

    user_count, artist_count, song_count = fetch_dashboard_counts

    render_html(res, 'dashboard', {
                  user_name: user.first_name,
                  user_role: user.role,
                  active_page: 'dashboard',
                  user_count: user_count,
                  artist_count: artist_count,
                  song_count: song_count,
                  my_artist_id: user.role == 'artist' ? ArtistService.find_by_user_id(user.id) : nil
                }, layout: 'dashboard', req: req)
  end

  private

  def fetch_dashboard_counts
    user_count = 0
    artist_count = 0
    song_count = 0

    db_connection do |db|
      user_count = db.exec_params('SELECT COUNT(*) AS total FROM users').first['total'].to_i
      artist_count = db.exec_params('SELECT COUNT(*) AS total FROM artists').first['total'].to_i
      song_count = db.exec_params('SELECT COUNT(*) AS total FROM songs').first['total'].to_i
    end

    [user_count, artist_count, song_count]
  end
end
