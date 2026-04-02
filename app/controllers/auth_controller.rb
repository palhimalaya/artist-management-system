class AuthController < ApplicationController
  def root(req, res)
    user = current_user(req)
    redirect(res, user ? '/dashboard' : '/login')
  end

  def login_page(req, res)
    user = current_user(req)
    return redirect(res, '/dashboard') if user

    render_html(res, 'login')
  end

  def register_page(req, res)
    user = current_user(req)
    return redirect(res, '/dashboard') if user

    render_html(res, 'register')
  end

  def register(req, res)
    user = build_user(req)

    errors = user.validate
    errors << 'Email already exists' if AuthService.find_by_email(user.email)

    return render_html(res, 'register', { error: errors.join(', ') }) if errors.any?

    user.password = HashUtil.hash_password(user.password)
    AuthService.create_user(user.to_h)

    redirect(res, '/login')
  end

  def login(req, res)
    data = parse_body(req)

    email = data['email']&.strip&.downcase
    password = data['password'].to_s

    user = AuthService.find_by_email(email)

    if valid_user?(user, password)
      set_session(res, user.id)
      redirect(res, '/dashboard')
    else
      render_html(res, 'login', { error: 'Invalid credentials' })
    end
  end

  def logout(_req, res)
    res['Set-Cookie'] = 'session=; Path=/; Max-Age=0'
    redirect(res, '/login')
  end

  private

  def build_user(req)
    data = parse_body(req)

    user = User.new(data)
    user.email = user.email.to_s.strip.downcase
    user.role = 'artist'

    user
  end

  def valid_user?(user, password)
    user && HashUtil.verify_password?(password, user.password)
  end
end
