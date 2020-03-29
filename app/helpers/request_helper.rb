module RequestHelper
  extend self

  def extract_title_from_page(url)
    title_from_response_body(fetch(url).body)
  end

  def title_from_response_body(body)
    title = body&.match(/<title.*?>(.*?)<\/title>/m)&.[](1)&.strip&.force_encoding('UTF-8')
    HTMLEntities.new.decode(title) if title
  end

  def url_from_param(param_value)
    URI.decode(param_value.strip)
  end

  private

  def fetch(uri_str, limit = 3)
    # Too many HTTP redirects, abandoning
    return '' if limit == 0

    url = URI.parse(uri_str)
    req = Net::HTTP::Get.new(url)
    req['Accept'] = 'text/html'
    response = Net::HTTP.start(url.host, url.port, use_ssl: true) { |http| http.request(req) }

    case response
    when Net::HTTPOK then response
    when Net::HTTPRedirection then fetch(response['location'], limit - 1)
    else
      response.error!
    end
  end
end
