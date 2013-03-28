class Changetwitteraccounts < ActiveRecord::Migration
	def up
		change_table :twitter_accounts do |t|
			t.change :name, :string
			t.change :comment, :string
			t.change :consumer_key, :string
			t.change :consumer_secret, :string
			t.change :oauth_token, :string
			t.change :oauth_token_secret, :string
			t.change :name, :string
			t.change :pause, :int, :default => 0
			t.change :last_used, :int , :default => 0
			t.change :last_checked, :int, :default => 0

		end
	end

	def down
	end
end
