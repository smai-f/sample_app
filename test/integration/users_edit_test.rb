require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:smai)
  end

  test 'successful edit with friendly forwarding' do
    new_name = 'Smoo'
    new_email = 'smoo@hey.com'
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    patch user_path(@user),
          params: { user: { name: new_name, email: new_email, password: '', password_confirmation: '' } }
    assert_redirected_to @user
    assert_nil session[:forwarding_url]
    assert_not flash.empty?
    @user.reload
    assert_equal @user.name, new_name
    assert_equal @user.email, new_email
  end

  test 'unsuccessful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    patch user_path(@user),
          params: { user: { name: '', email: 'user@invalid', password: 'foo', password_confirmation: 'bar' } }
    assert_template 'users/edit'
    assert_select 'div .alert', { text: 'Please fix the following 4 errors' }
  end
end
