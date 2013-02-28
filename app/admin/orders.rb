ActiveAdmin.register Order do
  form do |f|
    f.inputs 'User' do
      f.select("user_id", User.all.collect {|p| [ p.email, p.id ] })
    end
    f.inputs 'Order' do
      f.input :city
      f.input :product
      f.input :size
      f.input :name
      f.input :paypal_customer_token
      f.input :paypal_recurring_profile_token
    end
    f.actions
  end
end
