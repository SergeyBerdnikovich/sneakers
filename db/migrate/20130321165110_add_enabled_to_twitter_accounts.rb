class AddEnabledToTwitterAccounts < ActiveRecord::Migration
  def change
    add_column :twitter_accounts, :enabled, :boolean
  end
end
