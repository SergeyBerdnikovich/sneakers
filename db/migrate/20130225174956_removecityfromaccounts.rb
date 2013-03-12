class Removecityfromaccounts < ActiveRecord::Migration
  def up
  	remove_column :twitter_accounts, :city_id
  end

  def down
  	add_column :twitter_accounts, :city_id, :string
  end
end
