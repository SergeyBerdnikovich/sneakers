class PagesController < ApplicationController
  def welcome
    @gallery_for_slider = Gallery.for_slider
    @latest_products = Product.all

    gb = Gibbon.new("ba8bef03ff6ec6f2659a03ff0e92eea5-us6")
    @lists = gb.lists({:start => 0, :limit=> 100})["data"]
    @info = gb.list_members({:id => 'efb70bb866'})
  end

  def about_us
    @about_us = Page.last.about_us
  end

  def contact_us
    @contact_us = Page.last.contact_us
  end

  def faq
    @faq = Page.last.faq
  end

  def conditions
    @conditions = Page.last.conditions
  end
end
