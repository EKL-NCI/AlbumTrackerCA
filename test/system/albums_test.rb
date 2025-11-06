require "application_system_test_case"

class AlbumsTest < ApplicationSystemTestCase
  setup do
    @album = albums(:one)

    # Valid attributes for creating/updating
    @valid_album_params = {
      title: "Test Album",
      artist: "Test Artist",
      release_year: 2023,
      genre: "Pop",
      rating: 4,
      availability: true
    }
  end

  test "visiting the index" do
    visit albums_url
    assert_selector "h1", text: "Albums"
  end

  test "should create album" do
    visit albums_url
    click_on "Add New"

    fill_in "Title", with: @valid_album_params[:title]
    fill_in "Artist", with: @valid_album_params[:artist]
    fill_in "Release year", with: @valid_album_params[:release_year]
    fill_in "Genre", with: @valid_album_params[:genre]
    fill_in "Rating", with: @valid_album_params[:rating]
    check "Availability" if @valid_album_params[:availability]

    click_on "Create Album"

    assert_text "Album was successfully created"
    click_on "Back"
  end

  test "should update Album" do
    visit album_url(@album)
    click_on "Edit this album", match: :first

    fill_in "Title", with: @valid_album_params[:title]
    fill_in "Artist", with: @valid_album_params[:artist]
    fill_in "Release year", with: @valid_album_params[:release_year]
    fill_in "Genre", with: @valid_album_params[:genre]
    fill_in "Rating", with: @valid_album_params[:rating]
    check "Availability" if @valid_album_params[:availability]

    click_on "Update Album"

    assert_text "Album was successfully updated"
    click_on "Back"
  end

  test "should destroy Album" do
    visit album_url(@album)
    click_on "Destroy this album", match: :first

    assert_text "Album was successfully destroyed"
  end
end
