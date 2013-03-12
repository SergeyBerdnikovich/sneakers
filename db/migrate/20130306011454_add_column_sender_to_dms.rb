class AddColumnSenderToDms < ActiveRecord::Migration
  def change
    add_column :dms, :sender, :string
  end
end
