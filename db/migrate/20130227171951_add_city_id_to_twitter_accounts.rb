class AddCityIdToTwitterAccounts < ActiveRecord::Migration
  def change
    add_column :twitter_accounts, :city_id, :integer
  end
end
