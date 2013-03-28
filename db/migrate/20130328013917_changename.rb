class Changename < ActiveRecord::Migration
  def up
    	rename_column :orders, :TwitterAccountId, :twitter_AccountId
  	
  end

  def down
  end
end
