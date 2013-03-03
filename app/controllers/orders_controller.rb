class OrdersController < ApplicationController
  before_filter :authenticate_user!, :only => :index

  def new
    product = Product.find(params[:product_id])
    @order = product.orders.build
    if params[:PayerID]
      @order.paypal_customer_token = params[:PayerID]
      @order.paypal_recurring_profile_token = params[:token]
      @order.name = PayPal::Recurring.new(:token => params[:token]).checkout_details.email
      @order.paid = true
    end
  end

  def index
    @orders = Order.find_all_by_user_id(current_user.id)
  end

  def create
    @product = Product.find(params[:product_id])
    @order = Order.new(params[:order])
    @order.user = current_user
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

  def paypal_checkout
    product = Product.find(params[:product_id])
    ppr = PayPal::Recurring.new({
      return_url: new_product_order_url(:product_id => product.id),
      cancel_url: product_url(product.id),
      description: product.title,
      amount: product.cost,
      currency: "USD"
    })
    response = ppr.checkout
    if response.valid?
      redirect_to response.checkout_url
    else
      raise response.errors.inspect
    end
  end

  def charge_back
    @order = Order.find(params[:order_id])
    @order.charged_back == true ? @order.charged_back = false : @order.charged_back = true

    respond_to do |format|
      if @order.save
        format.html { redirect_to orders_path, notice: 'Charge back on this order has been completed.' }
        format.json { render json: @order, status: :created, location: @order }
      else
        format.html { render action: "new" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end
end
