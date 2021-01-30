require 'test_helper'

# Yes, I know, running tests that connect to the actual wild Internet
# will burn me one day, but for now this is fine :this-is-fine-dog:

class RequestHelperTest < ActiveSupport::TestCase
  test '.title_from_response_body parses non-utf8 characters' do
    expected = '«Nous devons agir maintenant», dit Theresa Tam'
    actual = RequestHelper.title_from_response_body("<title>\xC2\xABNous devons agir maintenant\xC2\xBB, dit Theresa Tam</title>")
    assert_equal expected, actual

    expected = 'Why I still use a ThinkPad X220 in 2019 — Maxime Vaillancourt'
    actual = RequestHelper.title_from_response_body("<title>\n    \n      Why I still use a ThinkPad X220 in 2019 &mdash; Maxime Vaillancourt\n    \n  </title>")
    assert_equal expected, actual

    expected = 'Foobar'
    actual = RequestHelper.title_from_response_body("<title data-enabled=\"true\">Foobar</title>")
    assert_equal expected, actual
  end

  test '.url_from_param decodes URIs' do
    expected = "https://2pml.us17.list-manage.com/track/click?u=e5c9ff1dc004212156ddfb8ed&id=1b3cee3d59&e=17acf5a6c2"
    actual = RequestHelper.url_from_param('https%3A%2F%2F2pml.us17.list-manage.com%2Ftrack%2Fclick%3Fu%3De5c9ff1dc004212156ddfb8ed%26id%3D1b3cee3d59%26e%3D17acf5a6c2')
    assert_equal expected, actual

    expected = 'https://google.com'
    actual = RequestHelper.url_from_param('https://google.com')
    assert_equal expected, actual
  end

  test '.url_from_param decodes non-ASCII URIs' do
    expected = "https://www.nexojornal.com.br/expresso/2020/04/09/A-confissão-da-Ecovias-sobre-contratos-com-o-governo-paulista"
    actual = RequestHelper.url_from_param('https://www.nexojornal.com.br/expresso/2020/04/09/A-confiss%C3%A3o-da-Ecovias-sobre-contratos-com-o-governo-paulista')
    assert_equal expected, actual
  end

  test '.extract_title_from_page uses https if possible' do
    expected_title = "Vous Etes Perdu ?"
    expected_uri = "https://perdu.com/"

    actual_title, actual_uri = RequestHelper.extract_title_from_page('http://perdu.com/')

    assert_equal expected_title, actual_title
    assert_equal expected_uri, actual_uri.to_s
  end

  test '.extract_title_from_page falls back to http if necessary' do
    expected_title = "NeverSSL - helping you get online"
    expected_uri = "http://neverssl.com/"

    actual_title, actual_uri = RequestHelper.extract_title_from_page('http://neverssl.com/')

    assert_equal expected_title, actual_title
    assert_equal expected_uri, actual_uri.to_s
  end

  test '.extract_title_from_page handles relative redirections' do
    expected_title = "A Short History of Bi-Directional Links"
    expected_uri = "https://maggieappleton.com/bidirectionals/"

    actual_title, actual_uri = RequestHelper.extract_title_from_page('https://maggieappleton.com/bidirectionals')

    assert_equal expected_title, actual_title
    assert_equal expected_uri, actual_uri.to_s
  end

  test '.extract_title_from_page handles multiple redirections' do
    expected_title = "The Business Value of Site Speed — And How to Analyze it Step by Step | by Ole Bossdorf | Project A Insights"
    expected_uri = "https://insights.project-a.com/the-business-value-of-site-speed-and-how-to-analyze-it-step-by-step"

    uri = 'https://calibreapp.us2.list-manage.com/track/click?u=9067434ef642e9c92aa7453d2&id=53148e0f59&e=df60486ca8'
    actual_title, actual_uri = RequestHelper.extract_title_from_page(uri)

    assert_equal expected_title, actual_title
    assert_includes actual_uri.to_s, expected_uri.to_s
  end
end
