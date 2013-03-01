class AddNewColumnToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :charged_back, :boolean
  end
end
