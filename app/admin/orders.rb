ActiveAdmin.register Order do
  index do
    column :id
    column :name
    column :size
    column :paid
    column :sent
    column :product do |order|
      order.product.title
    end
    column :city do |order|
      if order.city
        order.city.name
      end
    end
    column :twitter do |order|
      if order.city
        order.city.twitter
      end
    end
    column :twitter_account_id do |twitter_account|
      if twitter_account.city
        twitter_account.name
      end
    end
    column :paypal_customer_token
    column :paypal_recurring_profile_token
    column :charged_back
    column :charged_was_made

    default_actions
  end
  form do |f|
    f.inputs 'User' do
      f.select("user_id", User.all.collect {|p| [ p.email, p.id ] })
    end
    f.inputs 'Twitter account' do
      f.select("twitter_account_id", TwitterAccount.all.collect {|p| [ p.name, p.id ] })
    end
    f.inputs 'Order' do
      f.input :city
      f.input :product
      f.input :size
      f.input :name
      f.input :sent
      f.input :message
      f.input :charged_back
      f.input :charged_was_made
      f.input :paypal_customer_token
      f.input :paypal_recurring_profile_token
    end
    f.actions
  end
end
