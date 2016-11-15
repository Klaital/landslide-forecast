require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: {
                                    email: 'count-1@invalid',
                                    password: 'foo',
                                    password_confirmation: 'bar'
                      }}
    end
    assert_template 'users/new'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: {
                                    email: 'count-2@example.com',
                                    password: 'foobar',
                                    password_confirmation: 'foobar'
      }}
    end
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?, 'User is not logged in after signup'
  end
end
