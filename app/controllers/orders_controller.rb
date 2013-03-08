class OrdersController < ApplicationController
  before_filter :authenticate_user!, :only => :index

  def new
    product = Product.find(params[:product_id])
    @order = product.orders.build
  end

  def index
    @orders = Order.find_all_by_user_id(current_user.id)
  end

  def pay
    @order = Order.find(params[:id])
    if params[:PayerID]
      @order.paypal_customer_token = params[:PayerID]
      @order.paypal_recurring_profile_token = params[:token]
      @order.name = PayPal::Recurring.new(:token => params[:token]).checkout_details.email
      @order.paid = true
    end
  end

  def create
    product = Product.find(params[:product_id])
    @order = product.orders.new(params[:order])
    @order.user = current_user

    respond_to do |format|
      if @order.save
        format.html { redirect_to order_pay_path(@order.id), notice: 'Order was successfully created.' }
        format.json { render json: @order, status: :created, location: @order }
      else
        format.html { render action: "new" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    order = Order.find(params[:id])

    respond_to do |format|
      if order.update_attributes(params[:order])
        format.html { redirect_to orders_path, notice: 'Order got paid.' }
        format.json { head :no_content }
      else
        format.html { render action: "pay" }
        format.json { render json: order.errors, status: :unprocessable_entity }
      end
    end
  end

  def paypal_checkout
    product = Product.find(params[:product_id])
    order = Order.find(params[:order_id])
    ppr = PayPal::Recurring.new({
      return_url: order_pay_url(order.id),
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
    if @order.paid == true
      @order.charged_back == true ? @order.charged_back = false : @order.charged_back = true
    end

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
