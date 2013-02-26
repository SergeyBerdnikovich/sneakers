class CreateTwitterAccounts < ActiveRecord::Migration
  def change
    create_table :twitter_accounts do |t|
      t.integer :city_id
      t.text :name
      t.text :comment
      t.integer :last_checked
      t.text :consumer_key
      t.text :consumer_secret
      t.text :oauth_token
      t.text :oauth_token_secret

      t.timestamps
    end
  end
end
