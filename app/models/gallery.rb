class Gallery < ActiveRecord::Base
  belongs_to :product

  has_attached_file :image,
                    :styles => { :small => "50x50>",
                                 :for_product => "328x237>",
                                 :normal => "700x700>" },
                    :url  => "/images/gallery/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/images/gallery/:id/:style/:basename.:extension"

  validates_attachment_presence :image
  validates_attachment_size :image, :less_than => 3.megabytes
  validates_attachment_content_type :image,
                                    :content_type => ['image/jpg', 'image/jpeg', 'image/gif', 'image/png']

  attr_accessible :product_id, :image, :for_slider

  scope :for_slider, where(:for_slider => true)
end
