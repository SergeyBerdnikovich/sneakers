class OrdersController < ApplicationController
  def new
    @product = Product.find(params[:product_id])
    @order = Order.new
  end
  def create
    @product = Product.find(params[:product_id])
    @order = Order.new(params[:order])
    @order.product = @product

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order.product, notice: 'Order was successfully created.' }
        format.json { render json: @order, status: :created, location: @order }
      else
        format.html { render action: "new" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end
end