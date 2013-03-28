class CreateHashtags < ActiveRecord::Migration
  def change
    create_table :hashtags do |t|
      t.string :link
      t.integer :city_id
      t.integer :product_id
      t.string :hashtag
      t.string :received_from

      t.timestamps
    end
  end
end
