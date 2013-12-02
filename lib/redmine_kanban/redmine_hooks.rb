class RedmineHooks < Redmine::Hook::ViewListener
  include ApplicationHelper

  def view_layouts_base_html_head(context = {})
    tags = [stylesheet_link_tag("/plugin_assets/redmine_kanban/stylesheets/redmine_kanban_admin.css")]
    tags.join
  end
end
