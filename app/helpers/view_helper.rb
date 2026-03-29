require 'erb'

module ViewHelper
  ROLE_BADGE_CLASSES = {
    'super_admin' => 'bg-rose-50 text-rose-700 ring-1 ring-inset ring-rose-600/20',
    'artist_manager' => 'bg-blue-50 text-blue-700 ring-1 ring-inset ring-blue-600/20',
    'artist' => 'bg-gray-100 text-gray-700 ring-1 ring-inset ring-gray-500/20'
  }.freeze

  LAYOUT_DIR = 'app/views/layouts'.freeze

  def render_view(res, file_path, locals = {}, layout: 'application')
    layout_content = File.read(resolve_layout(layout))
    page_content = File.read(file_path)

    locals[:content] = ERB.new(page_content).result_with_hash(locals)

    if layout == 'dashboard'
      locals[:nav_html] = render_partial('nav', locals)
      locals[:sidebar_html] = render_partial('sidebar', locals)
    end

    html = ERB.new(layout_content).result_with_hash(locals)

    res['Content-Type'] = 'text/html'
    res.body = html
  end

  def render_partial(name, locals = {})
    content = File.read("app/views/_#{name}.html.erb")
    ERB.new(content).result_with_hash(locals)
  end

  def view(name)
    ->(_req, res) { render_view(res, "app/views/#{name}.html.erb") }
  end

  private

  def resolve_layout(name)
    "#{LAYOUT_DIR}/#{name}.html.erb"
  end
end
