ActiveAdmin.register Product do
  index do
    column :id
    column :title
    column :description
    column :cost
    column :release_date
    column :charged_back
    column :charge_back_comment
    column :created_at
    column :updated_at

    default_actions
  end

  form do |f|
    f.inputs "Product" do
      f.input :title
      f.input :description
      f.input :cost
      f.input :release_date
      f.input :charged_back
      f.input :charge_back_comment
    end
    f.inputs "Image",
      :for => [:galleries,
                if f.object.galleries.blank?
                  f.object.galleries.build
                else
                  f.object.galleries
                end
              ] do |fm|
      fm.input :image, :as => :file,
                       :hint => fm.template.image_tag(fm.object.image.url(:normal))
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :description
      row :cost
      row :release_date
      row :charged_back
      row :charge_back_comment
      row :created_at
      row :updated_at
      row :image do |house|
        render :partial => "/admin/galleries/gallery",
               :locals => { :obj => house }
      end
    end
    active_admin_comments
  end
end
