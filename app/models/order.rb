class Order < ActiveRecord::Base
  attr_accessible :city_id, :name, :paid, :payment_id, :product_id, :size

  belongs_to :city
  belongs_to :product
  belongs_to :user
end
