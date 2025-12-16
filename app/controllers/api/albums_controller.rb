module Api
  class AlbumsController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :set_album, only: %i[show update destroy]
    before_action :authenticate_user!, only: %i[create update destroy]
    before_action :authorize_admin!, only: %i[create update destroy]

    # GET /api/albums
    def index
      albums =
        if params[:q].present?
          q = params[:q].downcase
          Album.where(
            "LOWER(title) LIKE ? OR LOWER(artist) LIKE ?",
            "%#{q}%", "%#{q}%"
          )
        else
          Album.all
        end

      render json: albums.map { |a| AlbumSerializer.new(a).as_json }
    end

    # GET /api/albums/:id
    def show
      render json: AlbumSerializer.new(@album).as_json
    end

    # POST /api/albums
    def create
      album = Album.new(album_params)
      if album.save
        render json: AlbumSerializer.new(album).as_json, status: :created
      else
        render json: { errors: album.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PUT /api/albums/:id
    def update
      if @album.update(album_params)
        render json: AlbumSerializer.new(@album).as_json
      else
        render json: { errors: @album.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/albums/:id
    def destroy
      @album.destroy
      head :no_content
    end

    private

    def set_album
      @album = Album.find(params[:id])
    end

    def album_params
      params.require(:album).permit(
        :title,
        :artist,
        :release_year,
        :genre,
        :rating,
        :availability,
        :cover_image
      )
    end
  end
end