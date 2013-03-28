class CreateDmsToSends < ActiveRecord::Migration
  def change
    create_table :dms_to_sends do |t|
      t.string :message
      t.integer :twitter_account_id
      t.integer :hashtag_id

      t.timestamps
    end
  end
end
