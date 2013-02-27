class Product < ActiveRecord::Base
  attr_accessible :cost, :description, :title, :galleries_attributes

  has_many :galleries, :dependent => :destroy
  has_many :orders

  accepts_nested_attributes_for :galleries,
                                :allow_destroy => :true,
                                :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  validates :title,       :presence => true,
                          :uniqueness => true,
                          :length => { :minimum => 4, :maximum => 50 }
  validates :description, :presence => true
  validates :cost,        :numericality => { :greater_than => 0 },
                          :length => { :maximum => 10 }
  validates_associated :galleries
end
