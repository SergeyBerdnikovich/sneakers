class Dms < ActiveRecord::Base
  attr_accessible :received, :text, :twitter_account_id, :sender

  belongs_to :twitter_account
end
