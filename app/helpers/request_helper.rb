module RequestHelper
  extend self

  def extract_title_from_page(url)
    body = fetch(url).body
    title = body&.match(/<title.*>(.*)<\/title>/m)&.[](1)&.strip&.force_encoding('UTF-8')
    HTMLEntities.new.decode(title) if title
  end

  private

  def fetch(uri_str, limit = 3)
    # Too many HTTP redirects, abandoning
    return '' if limit == 0

    url = URI.parse(uri_str)
    req = Net::HTTP::Get.new(url)
    response = Net::HTTP.start(url.host, url.port, use_ssl: true) { |http| http.request(req) }

    case response
    when Net::HTTPOK then response
    when Net::HTTPRedirection then fetch(response['location'], limit - 1)
    else
      response.error!
    end
  end
end
