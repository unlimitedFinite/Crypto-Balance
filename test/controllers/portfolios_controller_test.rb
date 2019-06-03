require 'test_helper'

class PortfoliosControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get portfolios_new_url
    assert_response :success
  end

  test "should get create" do
    get portfolios_create_url
    assert_response :success
  end

  test "should get edit" do
    get portfolios_edit_url
    assert_response :success
  end

  test "should get update" do
    get portfolios_update_url
    assert_response :success
  end

  test "should get show" do
    get portfolios_show_url
    assert_response :success
  end

end
