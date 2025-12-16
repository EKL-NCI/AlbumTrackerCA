require "test_helper"

class ApiAlbumsTest < ActionDispatch::IntegrationTest
  setup do
    @album = albums(:one)

    # Common valid params
    @valid_params = {
      title: "Test Album",
      artist: "Test Artist",
      release_year: 2023,
      genre: "Pop",
      rating: 4,
      availability: true
    }
  end

  # Index/Home
  test "should list albums" do
    get "/api/albums"
    assert_response :success

    json = JSON.parse(response.body)
    assert json.is_a?(Array)
    assert json.any? { |a| a["id"] == @album.id }
  end

  # Show
  test "should show album" do
    get "/api/albums/#{@album.id}"
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal @album.title, json["title"]
    assert_equal @album.artist, json["artist"]
  end

  # Create
  test "should create album" do
    assert_difference("Album.count", 1) do
      post api_albums_url,
        params: {
          album: {
            title: "Test Album",
            artist: "Test Artist",
            release_year: 2000,
            genre: "Rock",
            rating: 4,
            availability: true
          }
        },
        as: :json
    end

    assert_response :created
  end

  # Update
  test "should update album" do
    album = albums(:one)

    patch api_album_url(album),
      params: {
        album: {
          title: "Updated Title",
          artist: album.artist,
          release_year: 2000,
          genre: album.genre,
          rating: album.rating,
          availability: album.availability
        }
      },
      as: :json

    assert_response :success
    assert_equal "Updated Title", album.reload.title
  end

  # Delete
  test "should destroy album" do
    assert_difference("Album.count", -1) do
      delete "/api/albums/#{@album.id}"
    end

    assert_response :no_content
  end
end
