# test/integration/albums_controller_test.rb
require "test_helper"

class ApiAlbumsTest < ActionDispatch::IntegrationTest
  # Use transactional tests to rollback after each test
  self.use_transactional_tests = true

  setup do
    # Clear albums and users before each test
    Album.delete_all
    User.delete_all

    # Create an admin user for authentication
    @admin_user = User.create!(
      email: "admin@example.com",
      password: "password",
      role: "admin"
    )

    # JWT headers for authenticated requests
    token = JwtService.encode(user_id: @admin_user.id, email: @admin_user.email, role: @admin_user.role)
    @headers = {
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json"
    }

    # Seed initial albums for testing
    @album1 = Album.create!(
      title: "Album One",
      artist: "Artist One",
      release_year: 2000,
      genre: "Rock",
      rating: 4,
      availability: true
    )

    @album2 = Album.create!(
      title: "Album Two",
      artist: "Artist Two",
      release_year: 2010,
      genre: "Pop",
      rating: 5,
      availability: true
    )
  end

  test "should get index" do
    get api_albums_url, headers: @headers
    assert_response :success

    albums = JSON.parse(response.body)
    assert_equal 2, albums.size
  end

  test "should show album" do
    get api_album_url(@album1), headers: @headers
    assert_response :success

    album = JSON.parse(response.body)
    assert_equal @album1.title, album["title"]
  end

  test "should create album" do
    album_params = {
      album: {
        title: "Album Three",
        artist: "Artist Three",
        release_year: 2022,
        genre: "Jazz",
        rating: 3,
        availability: true
      }
    }

    assert_difference("Album.count", 1) do
      post api_albums_url, params: album_params.to_json, headers: @headers
    end

    assert_response :created
  end

  test "should update album" do
    update_params = {
      album: {
        title: "Updated Album One",
        release_year: 2015
      }
    }

    patch api_album_url(@album1), params: update_params.to_json, headers: @headers
    assert_response :success

    @album1.reload
    assert_equal "Updated Album One", @album1.title
    assert_equal 2015, @album1.release_year
  end

  test "should destroy album" do
    assert_difference("Album.count", -1) do
      delete api_album_url(@album2), headers: @headers
    end

    assert_response :no_content
  end
end