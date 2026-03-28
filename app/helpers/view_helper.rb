module ViewHelper
  def render_view(res, file_path)
    layout = File.read('app/views/layout.html')
    content = File.read(file_path)

    html = layout.gsub('{{content}}', content)

    res['Content-Type'] = 'text/html'
    res.body = html
  end

  def view(name)
    ->(_req, res) { render_view(res, "app/views/#{name}.html") }
  end
end
