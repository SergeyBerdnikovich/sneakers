class AddSendedToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :sended, :boolean
  end
end
