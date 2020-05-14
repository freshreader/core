require 'test_helper'

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
    expected_title = "NeverSSL - Connecting ..."
    expected_uri = "http://neverssl.com/"

    actual_title, actual_uri = RequestHelper.extract_title_from_page('http://neverssl.com/')

    assert_equal expected_title, actual_title
    assert_equal expected_uri, actual_uri.to_s
  end
end
