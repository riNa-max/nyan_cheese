require "test_helper"

class AlbumPhotosControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get album_photos_show_url
    assert_response :success
  end
end
