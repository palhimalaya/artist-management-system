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

  def render_error(res, msg)
    res.status = 400
    res.body = msg
  end

  def render_html(res, template_name, locals = {}, layout: 'application')
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
