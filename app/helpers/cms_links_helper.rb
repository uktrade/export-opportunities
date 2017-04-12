module CmsLinksHelper
  def cms_url_for(path)
    base_uri = Figaro.env.cms_base_uri || '/'
    path = path.to_s
    path = path[1..-1] if path.starts_with?('/')

    base_uri + path
  end
end
