class AddChargedWasMadeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :charged_was_made, :boolean
  end
end
