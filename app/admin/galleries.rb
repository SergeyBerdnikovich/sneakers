ActiveAdmin.register Gallery do
  scope :all, :default => true
  scope :for_slider

  index do
    column :id
    column :image do |gallery|
      image_tag gallery.image.url(:small)
    end
    column 'Name', :image_file_name
    column 'Size', :image_file_size
    column 'Created at', :created_at
    column 'Updated at', :updated_at

    default_actions
  end

  form do |f|
    f.inputs "Product" do
      f.select("product_id", Product.all.collect {|p| [ p.title, p.id ] }, { :include_blank => true })
    end
    f.inputs "Image", :multipart => true do
      f.input :image, :as => :file, :hint => f.template.image_tag(f.object.image.url(:normal))
      f.input :for_slider, :label => "For slider?"
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :product do |gallery|
        link_to gallery.product.title, admin_product_path(gallery.product) if gallery.product
      end
      row :image_file_name
      row :image_content_type
      row :image_file_size
      row :created_at
      row :updated_at
      row :for_slider
      row :image do
        image_tag gallery.image.url(:normal)
      end
    end
    active_admin_comments
  end
end
