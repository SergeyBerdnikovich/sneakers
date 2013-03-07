ActiveAdmin.register Dms do
  index do
    column :id
    column :twitter_name do |dms|
      dms.twitter_account.name if dms.twitter_account
    end
    column :text
    column :received
    column :sender
    column :created_at
    column :updated_at

    default_actions
  end
end
