class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :city_id
      t.integer :product_id
      t.string :size
      t.string :name
      t.boolean :paid
      t.integer :payment_id

      t.timestamps
    end
  end
end
