class SongController < ApplicationController
  PER_PAGE = 10

  def index(req, res)
    user = current_user(req)
    artist_id = req.params['artist_id']

    artist = ArtistService.find(artist_id)
    unless artist
      res.status = 404
      redirect(res, '/dashboard')
      return
    end

    if (user.role == 'artist') && (artist.user_id&.to_s != user.id.to_s)
      res.status = 403
      redirect(res, '/dashboard')
      return
    end

    params = query_params(req)
    page = (params['page'] || '1').to_i
    page = 1 if page < 1

    total = SongService.count_by_artist(artist_id)
    total_pages = (total.to_f / PER_PAGE).ceil
    offset = (page - 1) * PER_PAGE

    songs = SongService.by_artist(artist_id, limit: PER_PAGE, offset: offset)

    can_manage = user.role == 'artist' && artist.user_id&.to_s == user.id.to_s

    render_html(res, 'songs/index', {
      user_name: user.first_name,
      user_role: user.role,
      active_page: 'songs',
      artist: artist,
      songs: songs,
      can_manage: can_manage,
      current_page: page,
      total_pages: total_pages,
      total_count: total
    }.merge(sidebar_locals(user)), layout: 'dashboard')
  end

  def new(req, res)
    user = current_user(req)
    artist_id = req.params['artist_id']

    artist = ArtistService.find(artist_id)
    unless artist && artist.user_id&.to_s == user.id.to_s
      res.status = 403
      redirect(res, '/dashboard')
      return
    end

    render_html(res, 'songs/new', {
      user_name: user.first_name,
      user_role: user.role,
      active_page: 'songs',
      artist: artist,
      error: nil,
      form_data: {}
    }.merge(sidebar_locals(user)), layout: 'dashboard')
  end

  def create(req, res)
    user = current_user(req)
    artist_id = req.params['artist_id']

    artist = ArtistService.find(artist_id)
    unless artist && artist.user_id&.to_s == user.id.to_s
      res.status = 403
      redirect(res, '/dashboard')
      return
    end

    data = parse_body(req)
    song = Song.new(data)
    errors = song.validate

    if errors.any?
      render_html(res, 'songs/new', {
        user_name: user.first_name,
        user_role: user.role,
        active_page: 'songs',
        artist: artist,
        error: errors.join(', '),
        form_data: data
      }.merge(sidebar_locals(user)), layout: 'dashboard')
      return
    end

    SongService.create(data.merge('artist_id' => artist_id, 'created_by' => user.id.to_s))
    redirect(res, "/artists/#{artist_id}/songs")
  end

  def edit(req, res)
    user = current_user(req)
    artist_id = req.params['artist_id']
    song_id = req.params['id']

    artist = ArtistService.find(artist_id)
    unless artist && artist.user_id&.to_s == user.id.to_s
      res.status = 403
      redirect(res, '/dashboard')
      return
    end

    song = SongService.find(song_id)

    unless song && song.artist_id.to_s == artist_id
      res.status = 404
      redirect(res, "/artists/#{artist_id}/songs")
      return
    end

    render_html(res, 'songs/edit', {
      user_name: user.first_name,
      user_role: user.role,
      active_page: 'songs',
      artist: artist,
      song: song,
      error: nil
    }.merge(sidebar_locals(user)), layout: 'dashboard')
  end

  def update(req, res)
    user = current_user(req)
    artist_id = req.params['artist_id']
    song_id = req.params['id']

    artist = ArtistService.find(artist_id)
    unless artist && artist.user_id&.to_s == user.id.to_s
      res.status = 403
      redirect(res, '/dashboard')
      return
    end

    data = parse_body(req)
    song = Song.new(data)
    errors = song.validate

    if errors.any?
      song.id = song_id
      song.artist_id = artist_id
      render_html(res, 'songs/edit', {
        user_name: user.first_name,
        user_role: user.role,
        active_page: 'songs',
        artist: artist,
        song: song,
        error: errors.join(', ')
      }.merge(sidebar_locals(user)), layout: 'dashboard')
      return
    end

    SongService.update(song_id, data)
    redirect(res, "/artists/#{artist_id}/songs")
  end

  def delete(req, res)
    user = current_user(req)
    artist_id = req.params['artist_id']
    song_id = req.params['id']

    artist = ArtistService.find(artist_id)
    unless artist && artist.user_id&.to_s == user.id.to_s
      res.status = 403
      redirect(res, '/dashboard')
      return
    end

    SongService.delete(song_id)
    redirect(res, "/artists/#{artist_id}/songs")
  end

  private

  def sidebar_locals(user)
    { my_artist_id: user.role == 'artist' ? ArtistService.find_by_user_id(user.id) : nil }
  end
end
