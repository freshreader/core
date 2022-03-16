require 'httparty'

module RequestHelper
  extend self

  def extract_title_from_page(url)
    response = fetch_with_fallback(url)
    title = title_from_response_body(response.body)
    [title, response.request.last_uri.to_s]
  end

  def title_from_response_body(body)
    title = body&.match(/<title.*?>(.*?)<\/title>/m)&.[](1)&.strip&.force_encoding('UTF-8')
    HTMLEntities.new.decode(title) if title
  end

  def url_from_param(param_value)
    URI::Parser.new.unescape(param_value.strip)
  end

  private

  def fetch_with_fallback(uri_str)
    do_fetch(uri_str.sub('http://', 'https://'))
  rescue
    do_fetch(uri_str)
  end

  def do_fetch(uri_str)
    unless uri_str.start_with?('http://') || uri_str.start_with?('https://') || uri_str.start_with?('//')
      uri_str = "https://#{uri_str}"
    end

    HTTParty.get(URI::Parser.new.escape(uri_str))
  end
end
