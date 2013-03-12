class CreateGalleries < ActiveRecord::Migration
  def change
    create_table :galleries do |t|
      t.references :product
      t.attachment :image
      t.boolean :for_slider
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size

      t.timestamps
    end
    add_index :galleries, :product_id
  end
end