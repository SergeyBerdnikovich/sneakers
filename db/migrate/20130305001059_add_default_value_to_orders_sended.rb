class AddDefaultValueToOrdersSended < ActiveRecord::Migration
  def change
  	  change_column :orders, :sended, :boolean, :default => false
  end
end
