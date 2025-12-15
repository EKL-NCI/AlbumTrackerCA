class Api::AlbumsController < ApplicationController
  before_action :set_album, only: %i[ show update destroy ]

  def index
    albums = if params[:q].present?
      query = params[:q].downcase
      Album.where("LOWER(title) LIKE ? OR LOWER(artist) LIKE ?", "%#{query}%", "%#{query}%")
    else
      Album.all
    end

    render json: albums.map { |a| AlbumSerializer.new(a).as_json }
  end

  def show
    render json: AlbumSerializer.new(@album).as_json
  end

  def create
    album = Album.new(album_params)
    album.save!
    render json: AlbumSerializer.new(album).as_json, status: :created
  end

  def update
    @album.update!(album_params)
    render json: AlbumSerializer.new(@album).as_json
  end

  def destroy
    @album.destroy!
    head :no_content
  end

  private

  def set_album
    @album = Album.find(params[:id])
  end

  def album_params
    params.permit(:title, :artist, :release_year, :genre, :rating, :availability, :cover_image)
  end
end
