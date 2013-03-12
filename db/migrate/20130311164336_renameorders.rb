class Renameorders < ActiveRecord::Migration
  def up
  	rename_column :orders, :sended, :sent
  end

  def down
  end
end
