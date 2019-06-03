require 'test_helper'

class OrdersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get orders_new_url
    assert_response :success
  end

  test "should get create" do
    get orders_create_url
    assert_response :success
  end

  test "should get index" do
    get orders_index_url
    assert_response :success
  end

  test "should get update" do
    get orders_update_url
    assert_response :success
  end

end
