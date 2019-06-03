require 'test_helper'

class CoinsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get coins_index_url
    assert_response :success
  end

  test "should get update" do
    get coins_update_url
    assert_response :success
  end

end
