
class PagesController < ApplicationController
  def welcome
    @gallery_for_slider = Gallery.for_slider
    @last_products = Product.limit(6)

    gb = Gibbon.new("ba8bef03ff6ec6f2659a03ff0e92eea5-us6")
    @lists = gb.lists({:start => 0, :limit=> 100})["data"]
    @info = gb.list_members({:id => 'efb70bb866'})
  end
end
