class AddFollowingToTwitterAccounts < ActiveRecord::Migration
  def change
    add_column :twitter_accounts, :follwing, :string
  end
end
