class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.text :about_us
      t.text :faq
      t.text :contact_us
      t.text :conditions

      t.timestamps
    end
  end
end
