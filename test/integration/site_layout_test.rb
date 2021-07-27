require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def assert_title(title = '')
    assert_select 'title', full_title(title)
  end

  test 'layout links' do
    get root_path
    assert_template 'static_pages/home'
    assert_select 'a[href=?]', root_path, count: 2
    assert_select 'a[href=?]', help_path
    assert_select 'a[href=?]', about_path
    assert_select 'a[href=?]', contact_path
  end

  test 'page titles' do
    get root_path
    assert_title
    get contact_path
    assert_title 'Contact'
    get help_path
    assert_title 'Help'
    get about_path
    assert_title 'About'
  end
end
