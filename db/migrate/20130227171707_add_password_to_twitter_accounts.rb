class AddPasswordToTwitterAccounts < ActiveRecord::Migration
  def change
    add_column :twitter_accounts, :password, :string
  end
end
