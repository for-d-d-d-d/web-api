require 'test_helper'

class JsonControllerTest < ActionController::TestCase
  test "should get song" do
    get :song
    assert_response :success
  end

end
