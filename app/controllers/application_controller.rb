require 'json'

class ApplicationController
  include AuthHelper
  include ViewHelper

  private

  def parse_body(req)
    return {} unless req.body

    URI.decode_www_form(req.body).to_h
  end

  def set_session(res, user_id)
    session = CookieUtil.generate(user_id)
    res['Set-Cookie'] = "session=#{session}; Path=/; HttpOnly"
  end

  def current_user(req)
    return req.instance_variable_get(:@current_user) if req.instance_variable_defined?(:@current_user)

    cookies = CookieUtil.parse(req['Cookie'])
    session = cookies['session']

    user_id = CookieUtil.verify(session)
    return nil unless user_id

    user = UserService.find(user_id)

    req.instance_variable_set(:@current_user, user)
  end

  def redirect(res, path)
    res.status = 302
    res['Location'] = path
  end

  def set_flash(res, type, message)
    payload = "#{type}|#{message}"
    encoded = URI.encode_www_form_component(payload)
    res['Set-Cookie'] = "flash=#{encoded}; Path=/; Max-Age=5"
  end

  def get_flash(req)
    cookies = CookieUtil.parse(req['Cookie'])
    raw = cookies['flash']
    return nil unless raw

    decoded = URI.decode_www_form_component(raw)
    type, message = decoded.split('|', 2)
    { type: type, message: message }
  rescue StandardError
    nil
  end

  def clear_flash(res)
    res['Set-Cookie'] = "flash=; Path=/; Max-Age=0"
  end

  def render_error(res, msg)
    res.status = 400
    res.body = msg
  end

  def render_html(res, template_name, locals = {}, layout: 'application', req: nil)
    if req
      flash = get_flash(req)
      clear_flash(res) if flash
      locals[:flash_message] = flash
    end
    render_view(res, "app/views/#{template_name}.html.erb", locals, layout:)
  end

  def json_response(res, data, status: 200)
    res.status = status
    res['Content-Type'] = 'application/json'
    res.body = data.to_json
  end

  def query_params(req)
    query = req.query
    return {} if query.nil? || query.empty?

    query.is_a?(Hash) ? query.transform_keys(&:to_s) : URI.decode_www_form(query).to_h
  end
end
