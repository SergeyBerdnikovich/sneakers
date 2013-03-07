class CreateDms < ActiveRecord::Migration
  def change
    create_table :dms do |t|
      t.integer :twitter_account_id
      t.string :text
      t.datetime :received

      t.timestamps
    end
  end
end
