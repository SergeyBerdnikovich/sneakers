require 'sanitize/sanitize.rb'
ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    div :class => "blank_slate_container", :id => "dashboard_default_message" do
      span :class => "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end

    # Here is an example of a simple dashboard with columns and panels.
    #
     columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

       column do
         panel "Newsletter" do
           li  "<script type='text/javascript' language='JavaScript' src='http://facebook.us6.list-manage.com/subscriber-count?b=36&u=29ced2e7-8826-427d-84e4-edbd1d24c7cf&id=efb70bb866'></script>".html_safe
         end
       end
     end
  end # content
end
