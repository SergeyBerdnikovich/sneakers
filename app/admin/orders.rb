ActiveAdmin.register Order do
  index do
    column :id
    column :name
    column :size
    column :paid
    column :sended
    column :charged_back
    column :charged_was_made
    column :city do |order|
      order.city.name
    end
    column :twitter do |order|
      order.city.twitter
    end
    column :paypal_customer_token
    column :paypal_recurring_profile_token
    column :created_at
    column :updated_at

    default_actions
  end
  form do |f|
    f.inputs 'User' do
      f.select("user_id", User.all.collect {|p| [ p.email, p.id ] })
    end
    f.inputs 'Order' do
      f.input :city
      f.input :product
      f.input :size
      f.input :name
      f.input :sended
      f.input :message
      f.input :charged_back
      f.input :charged_was_made
      f.input :paypal_customer_token
      f.input :paypal_recurring_profile_token
    end
    f.actions
  end
end
