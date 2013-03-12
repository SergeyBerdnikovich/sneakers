class AddWorksToTwitterAccounts < ActiveRecord::Migration
  def change
    add_column :twitter_accounts, :works, :boolean
  end
end
