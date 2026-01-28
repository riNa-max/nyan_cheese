require "test_helper"

class ShareLinksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get share_links_index_url
    assert_response :success
  end
end
