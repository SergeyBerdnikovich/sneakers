class TwitterAccount < ActiveRecord::Base
  attr_accessible :city_id, :comment, :consumer_key, :consumer_secret, :last_checked, :name, :oauth_token, :oauth_token_secret
  belongs_to :city
end
