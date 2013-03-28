class AddTwitterAccountIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :TwitterAccountId, :integer
  end
end
