class User < ActiveRecord::Base
	  # Setup accessible (or protected) attributes for your model
  attr_accessible  :email ,
  :encrypted_password  ,
  :password,
  :password_confirmation,
  :reset_password_token,
  :reset_password_sent_at,
  :remember_created_at,
  :sign_in_count     ,
  :current_sign_in_at,
  :last_sign_in_at,
  :current_sign_in_ip,
  :last_sign_in_ip,
  :created_at         ,
  :updated_at            
  # attr_accessible :title, :body
  has_many :orders, :dependent => :destroy
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


end
