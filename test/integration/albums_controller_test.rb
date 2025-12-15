require "test_helper"

class ApiAlbumsTest < ActionDispatch::IntegrationTest
  setup do
    @album = albums(:one)

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
      post "/api/albums", params: @valid_params
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal @valid_params[:title], json["title"]
    assert_equal @valid_params[:artist], json["artist"]
  end

  # Update
  test "should update album" do
    patch "/api/albums/#{@album.id}", params: @valid_params.merge(title: "Updated Title")
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal "Updated Title", json["title"]
    assert_equal @valid_params[:artist], json["artist"]
  end

  # Delete
  test "should destroy album" do
    assert_difference("Album.count", -1) do
      delete "/api/albums/#{@album.id}"
    end

    assert_response :no_content
  end
end
