require "test_helper"

class SharesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get shares_show_url
    assert_response :success
  end
end
