class ArtistController < ApplicationController
  PER_PAGE = 10

  def index(req, res)
    user = current_user(req)

    params = query_params(req)
    page = (params['page'] || '1').to_i
    page = 1 if page < 1

    total = ArtistService.count
    total_pages = (total.to_f / PER_PAGE).ceil
    offset = (page - 1) * PER_PAGE

    artists = ArtistService.all(limit: PER_PAGE, offset: offset)

    render_html(res, 'artists/index', {
                  user_name: user.first_name,
                  user_role: user.role,
                  active_page: 'artists',
                  artists: artists,
                  can_manage: user.role == 'artist_manager',
                  current_page: page,
                  total_pages: total_pages,
                  total_count: total
                }, layout: 'dashboard', req: req)
  end

  def new(req, res)
    user = current_user(req)

    render_html(res, 'artists/new', {
                  user_name: user.first_name,
                  user_role: user.role,
                  active_page: 'artists',
                  error: nil,
                  form_data: {}
                }, layout: 'dashboard', req: req)
  end

  def create(req, res)
    user = current_user(req)
    data = parse_body(req)

    artist = Artist.new(data)
    errors = artist.validate

    if errors.any?
      render_html(res, 'artists/new', {
                    user_name: user.first_name,
                    user_role: user.role,
                    active_page: 'artists',
                    error: errors.join(', '),
                    form_data: data
                  }, layout: 'dashboard', req: req)
      return
    end

    ArtistService.create(data.merge('created_by' => user.id.to_s))
    set_flash(res, 'success', 'Artist created successfully')
    redirect(res, '/artists')
  end

  def edit(req, res)
    user = current_user(req)
    id = req.params['id']

    artist = ArtistService.find(id)

    unless artist
      res.status = 404
      redirect(res, '/artists')
      return
    end

    available_users = ArtistService.unlinked_artist_users
    linked_user = ArtistService.linked_user_for(id)

    render_html(res, 'artists/edit', {
                  user_name: user.first_name,
                  user_role: user.role,
                  active_page: 'artists',
                  artist: artist,
                  available_users: available_users,
                  linked_user: linked_user,
                  can_manage: true,
                  error: nil
                }, layout: 'dashboard', req: req)
  end

  def update(req, res)
    user = current_user(req)
    id = req.params['id']
    data = parse_body(req)

    artist = Artist.new(data)
    errors = artist.validate

    if errors.any?
      artist.id = id
      available_users = ArtistService.unlinked_artist_users
      linked_user = ArtistService.linked_user_for(id)

      render_html(res, 'artists/edit', {
                    user_name: user.first_name,
                    user_role: user.role,
                    active_page: 'artists',
                    artist: artist,
                    available_users: available_users,
                    linked_user: linked_user,
                    can_manage: true,
                    error: errors.join(', ')
                  }, layout: 'dashboard', req: req)
      return
    end

    ArtistService.update(id, data)

    # Handle user linking
    link_action = data['link_action']
    if link_action == 'link' && !data['user_id'].to_s.strip.empty?
      ArtistService.link_user(id, data['user_id'])
    elsif link_action == 'unlink'
      ArtistService.unlink_user(id)
    end

    set_flash(res, 'success', 'Artist updated successfully')
    redirect(res, '/artists')
  end

  def delete(req, res)
    id = req.params['id']
    ArtistService.delete(id)
    set_flash(res, 'success', 'Artist deleted successfully')
    redirect(res, '/artists')
  end

  def export_csv(_req, res)
    csv_data = ArtistService.to_csv
    filename = "artists_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"

    res['Content-Type'] = 'text/csv'
    res['Content-Disposition'] = "attachment; filename=\"#{filename}\""
    res.body = csv_data
  end

  def import_csv(req, res)
    user = current_user(req)
    data = parse_body(req)
    csv_text = data['csv_text']

    if csv_text.nil? || csv_text.strip.empty?
      set_flash(res, 'error', 'CSV data is required')
      redirect(res, '/artists')
      return
    end

    result = ArtistService.import_csv(csv_text, user.id)

    if result[:errors].any?
      set_flash(res, 'error',
                "Created #{result[:created]}, updated #{result[:updated]}. Errors: #{result[:errors].join('; ')}")
    else
      parts = []
      parts << "#{result[:created]} created" if result[:created].positive?
      parts << "#{result[:updated]} updated" if result[:updated].positive?
      set_flash(res, 'success', "Import complete: #{parts.join(', ')}")
    end
    redirect(res, '/artists')
  end
end
