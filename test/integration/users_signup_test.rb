require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test 'invalid signup information' do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: '', email: 'user@invalid', password: '', password_confirmation: '' } }
    end
    assert_template 'users/new'
    assert_select '.sign_up_form li' do |lis|
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
           params: { user: { name: 'Example User', email: 'blah@example.com', password: 'password',
                             password_confirmation: 'password' } }
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert is_logged_in?
  end
end
