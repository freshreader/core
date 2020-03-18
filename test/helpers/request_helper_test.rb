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
end
