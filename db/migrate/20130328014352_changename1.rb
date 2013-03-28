class Changename1 < ActiveRecord::Migration
  def up
    	rename_column :orders, :twitter_AccountId, :twitter_account_id
  	  end

  def down
  end
end
