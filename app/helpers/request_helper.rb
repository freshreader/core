module RequestHelper
  extend self

  def extract_title_from_page(url)
    response = fetch_with_fallback(url)
    title = title_from_response_body(response.body)
    [title, response.uri]
  end

  def title_from_response_body(body)
    title = body&.match(/<title.*?>(.*?)<\/title>/m)&.[](1)&.strip&.force_encoding('UTF-8')
    HTMLEntities.new.decode(title) if title
  end

  def url_from_param(param_value)
    URI.decode(param_value.strip)
  end

  private

  def fetch_with_fallback(uri_str)
    do_fetch(uri_str.sub('http://', 'https://'))
  rescue
    do_fetch(uri_str, use_ssl: false)
  end

  def do_fetch(uri_str, limit: 3, use_ssl: true)
    # Too many HTTP redirects, abandoning
    return '' if limit == 0

    unless uri_str.start_with?('http://') || uri_str.start_with?('https://') || uri_str.start_with?('//')
      uri_str = "https://#{uri_str}"
    end

    url = URI.parse(URI.escape(uri_str))
    req = Net::HTTP::Get.new(url)
    req['Accept'] = 'text/html'

    options = {
      use_ssl: use_ssl,
      open_timeout: 4,
      read_timeout: 8,
    }

    response = Net::HTTP.start(url.host, url.port, options) do |http|
      http.request(req)
    end

    case response
    when Net::HTTPOK then response
    when Net::HTTPRedirection then
      location_header_value = response['location']
      redirect_url = if location_header_value.start_with?('/')
        "#{use_ssl ? 'https://' : 'http://'}#{url.host}#{location_header_value}"
      else
        location_header_value
      end

      do_fetch(redirect_url, limit: limit - 1)
    else
      response.error!
    end
  end
end
