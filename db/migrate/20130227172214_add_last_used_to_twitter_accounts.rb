class AddLastUsedToTwitterAccounts < ActiveRecord::Migration
  def change
    add_column :twitter_accounts, :last_used, :integer
  end
end
