class AddPaypalToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :paypal_customer_token, :string
    add_column :orders, :paypal_recurring_profile_token, :string
  end
end
