require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: 'Example User', email: 'user@example.com',
                     password: 'foobar', password_confirmation: 'foobar')
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'name should be present' do
    @user.name = '     '
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = ' '
    assert_not @user.valid?
  end

  test 'name should not be too long' do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test 'email should not be too long' do
    @user.email = "#{'a' * 244}@example.com"
    assert_not @user.valid?
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w[user@example.com USER@Foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]

    valid_addresses.each do |address|
      @user.email = address
      assert @user.valid?, "Address #{address.inspect} should be valid"
    end
  end

  test 'email validation should reject invalid addresses' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]

    invalid_addresses.each do |address|
      @user.email = address
      assert_not @user.valid?, "Address #{address.inspect} should be invalid"
    end
  end

  test 'email address should be unique' do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email should be saved as lower case' do
    mixed_case_email = 'tEsT@eMaIl.CoM'
    @user.email = mixed_case_email
    @user.save
    assert_equal @user.reload.email, mixed_case_email.downcase
  end

  test 'password should be present' do
    @user.password = @user.password_confirmation = '          '
    assert_not @user.valid?
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end

  test 'authenticated? should return false for a user with nil digest' do
    assert_not @user.authenticated?(:remember, '')
  end

  test 'associated microposts should be destroyed when user destroyed' do
    @user.save
    @user.microposts.create!(content: 'About to be destroyed')
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test 'should follow and unfollow a user' do
    smai = users(:smai)
    other = users(:user_10)
    assert_not smai.following?(other)
    smai.follow(other)
    assert smai.following?(other)
    assert other.followers.include?(smai)
    smai.unfollow(other)
    assert_not smai.following?(other)
    smai.follow(smai)
    assert_not smai.following?(smai)
  end

  test 'feed should have the right posts' do
    smai = users(:smai)
    other = users(:user_19)
    user_8 = users(:user_8)
    # Posts from followed user
    user_8.microposts.each do |post_following|
      assert smai.feed.include?(post_following)
    end
    # Self-posts for user with followers
    smai.microposts.each do |post_self|
      assert smai.feed.include?(post_self)
    end
    # Self-posts for user with no followers
    other.microposts.each do |post_self|
      assert other.feed.include?(post_self)
    end
    # Posts from unfollowed user
    other.microposts.each do |post_unfollowed|
      assert_not smai.feed.include?(post_unfollowed)
    end
  end
end
