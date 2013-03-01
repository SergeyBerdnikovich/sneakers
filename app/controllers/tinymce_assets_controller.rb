class TinymceAssetsController < ApplicationController
  def create
    gallery = Gallery.create!(:image => params[:file])

    render json: {
      image: {
        url: gallery.image.url(:normal)
      }
    }, content_type: "text/html"
  end
end