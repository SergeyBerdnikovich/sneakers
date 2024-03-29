class Order < ActiveRecord::Base
  attr_accessible :city_id, :name, :paid, :payment_id, :product_id,
                  :size, :paypal_recurring_profile_token, :paypal_customer_token,
                  :user_id, :charged_back, :charged_was_made, :sent, :twitter_account_id, :message

  belongs_to :city
  belongs_to :product
  belongs_to :user
  belongs_to :twitter_account

  def payment_provided?
    paypal_recurring_profile_token.present?
  end
end
