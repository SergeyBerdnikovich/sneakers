class AddPauseToTwitterAccounts < ActiveRecord::Migration
  def change
    add_column :twitter_accounts, :pause, :float
  end
end
