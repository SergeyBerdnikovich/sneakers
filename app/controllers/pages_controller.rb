class PagesController < ApplicationController
  def welcome
    @gallery_for_slider = Gallery.for_slider
    @last_products = Product.limit(6)
  end
end
