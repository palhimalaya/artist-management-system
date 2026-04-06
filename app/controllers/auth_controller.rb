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

    errors = user.validate(
      email_taken: AuthService.find_by_email(user.email),
      require_password_confirmation: true,
      require_strong_password: true
    )

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
      if json_request?(req)
        token = JwtUtil.generate(user)
        json_response(res, { token: token, user: user.as_json })
      else
        set_session(res, user.id)
        redirect(res, '/dashboard')
      end
    else
      if json_request?(req)
        json_response(res, { error: 'Invalid credentials' }, status: 401)
      else
        render_html(res, 'login', { error: 'Invalid credentials' })
      end
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
