class AddColumnsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :charged_back, :boolean
    add_column :products, :release_date, :datetime
    add_column :products, :charge_back_comment, :string
  end
end
