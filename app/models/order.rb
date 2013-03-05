class Order < ActiveRecord::Base
  attr_accessible :city_id, :name, :paid, :payment_id, :product_id,
                  :size, :paypal_recurring_profile_token, :paypal_customer_token,
<<<<<<< HEAD
                  :user_id, :charged_back, :charged_was_made
=======
                  :user_id, :charged_back, :charged_was_made, :sended, :message
>>>>>>> d3f1c8298c3fd14509210dc620cb8bdd95518d3b

  belongs_to :city
  belongs_to :product
  belongs_to :user

  def payment_provided?
    paypal_recurring_profile_token.present?
  end
end
