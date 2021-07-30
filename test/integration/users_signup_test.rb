require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end
  test 'invalid signup information' do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: '', email: 'user@invalid', password: ' ', password_confirmation: ' ' } }
    end
    assert_template 'users/new'
    assert_select 'li' do |lis|
      error_messages = lis.map(&:to_s)

      # Not actually a good idea to verify underlying Rails messages, just trying stuff.
      expected_errors = ["Name can't be blank", 'Email is invalid', "Password can't be blank", 'Password is too short']
      expected_errors.each do |m|
        assert error_messages.any? { |msg|
                 msg.include?(m)
               }, "Expected error message #{m} not present"
      end
    end
  end

  test 'valid signup information' do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path,
           params: { user: { name: 'Example User', email: 'new@example.com', password: 'password',
                             password_confirmation: 'password' } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path('invalid token', email: user.email)
    assert_not is_logged_in?
    get edit_account_activation_path(user.activation_token, email: 'wrong@hey.com')
    assert_not is_logged_in?
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
