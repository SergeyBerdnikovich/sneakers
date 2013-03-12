class RenameFollowing < ActiveRecord::Migration
  def up
  	
  	rename_column :twitter_accounts, :follwing, :following
  end

  def down
  end
end
