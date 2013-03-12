ActiveAdmin.register Page do
  form :partial => "pages_form"

  controller do
    def create
      params[:page][:about_us] = TunedSanitize::for_(params[:page][:about_us])
      params[:page][:contact_us] = TunedSanitize::for_(params[:page][:contact_us])
      params[:page][:faq] = TunedSanitize::for_(params[:page][:faq])
      params[:page][:conditions] = TunedSanitize::for_(params[:page][:conditions])
      create!
    end
    def update
      params[:page][:about_us] = TunedSanitize::for_(params[:page][:about_us])
      params[:page][:contact_us] = TunedSanitize::for_(params[:page][:contact_us])
      params[:page][:faq] = TunedSanitize::for_(params[:page][:faq])
      params[:page][:conditions] = TunedSanitize::for_(params[:page][:conditions])
      update!
    end
  end

  show do
    attributes_table do
      row :id
      row :about_us do |page|
        TunedSanitize::for_(page.about_us).html_safe
      end
      row :contact_us do |page|
        TunedSanitize::for_(page.contact_us).html_safe
      end
      row :faq do |page|
        TunedSanitize::for_(page.faq).html_safe
      end
      row :conditions do |page|
        TunedSanitize::for_(page.conditions).html_safe
      end
    end
    active_admin_comments
  end
end