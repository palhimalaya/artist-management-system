require 'json'

class UserController < ApplicationController
  PER_PAGE = 10

  def index(req, res)
    user = current_user(req)

    params = query_params(req)
    page = (params['page'] || '1').to_i
    page = 1 if page < 1

    total = UserService.count
    total_pages = (total.to_f / PER_PAGE).ceil
    offset = (page - 1) * PER_PAGE

    users = UserService.all(limit: PER_PAGE, offset: offset)

    render_html(res, 'users/index', {
                  user_name: user.first_name,
                  user_role: user.role,
                  active_page: 'users',
                  users: users,
                  role_badges: ViewHelper::ROLE_BADGE_CLASSES,
                  current_page: page,
                  total_pages: total_pages,
                  total_count: total
                }, layout: 'dashboard', req: req)
  end

  def new(req, res)
    user = current_user(req)

    render_html(res, 'users/new', {
                  user_name: user.first_name,
                  user_role: user.role,
                  active_page: 'users',
                  error: nil,
                  form_data: {}
                }, layout: 'dashboard', req: req)
  end

  def create(req, res)
    user = current_user(req)
    data = parse_body(req)

    new_user = User.new(data)
    errors = new_user.validate

    existing = AuthService.find_by_email(data['email']&.strip&.downcase)
    errors << 'Email already exists' if existing

    if errors.any?
      render_html(res, 'users/new', {
                    user_name: user.first_name,
                    user_role: user.role,
                    active_page: 'users',
                    error: errors.join(', '),
                    form_data: data
                  }, layout: 'dashboard', req: req)
      return
    end

    new_user.password = HashUtil.hash_password(new_user.password)
    UserService.create(data.merge('password' => new_user.password))

    set_flash(res, 'success', 'User created successfully')
    redirect(res, '/users')
  end

  def edit(req, res)
    user = current_user(req)
    id = req.params['id']

    edit_user = UserService.find(id)

    unless edit_user
      res.status = 404
      redirect(res, '/users')
      return
    end

    render_html(res, 'users/edit', {
                  user_name: user.first_name,
                  user_role: user.role,
                  active_page: 'users',
                  user: edit_user,
                  error: nil
                }, layout: 'dashboard', req: req)
  end

  def update(req, res)
    user = current_user(req)
    id = req.params['id']
    data = parse_body(req)

    edit_user = User.new(data)
    errors = edit_user.validate
    errors.delete('Password required')

    if errors.any?
      edit_user.id = id
      render_html(res, 'users/edit', {
                    user_name: user.first_name,
                    user_role: user.role,
                    active_page: 'users',
                    user: edit_user,
                    error: errors.join(', ')
                  }, layout: 'dashboard', req: req)
      return
    end

    UserService.update(id, data)
    set_flash(res, 'success', 'User updated successfully')
    redirect(res, '/users')
  end

  def delete(req, res)
    id = req.params['id']
    UserService.delete(id)
    set_flash(res, 'success', 'User deleted successfully')
    redirect(res, '/users')
  end
end
