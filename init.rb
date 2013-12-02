require 'redmine'
require 'aasm'
require "block_helpers"
require 'redmine_kanban/redmine_hooks'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'issue'
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  unless Issue.included_modules.include? RedmineKanban::IssuePatch
    Issue.send(:include, RedmineKanban::IssuePatch)
  end
end


Redmine::Plugin.register :redmine_kanban do
  name 'Kanban'
  author 'Eric Davis'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-kanban'
  author_url 'http://www.littlestreamsoftware.com'
  description 'The Redmine Kanban plugin is used to manage issues according to the Kanban system of project management.'
  version '0.2.1'

  requires_redmine :version_or_higher => '2.2'

  permission(:view_kanban, {:kanbans => [:show], :kanbaniterations => [:show]})
  permission(:edit_kanban, {:kanbans => [:update, :sync], :kanbaniterations => [:update, :sync]})
  permission(:manage_kanban, {})
  
  settings(:partial => 'settings/kanban_settings',
           :default => {
             'panes' => {
               'incoming' => { 'status' => nil, 'limit' => 5},
               'backlog' => { 'status' => nil, 'limit' => 15},
               'selected' => { 'status' => nil, 'limit' => 8},
               'quick-tasks' => {'limit' => 5},
               'active' => { 'status' => nil, 'limit' => 5},
               'testing' => { 'status' => nil, 'limit' => 5},
               'finished' => {'status' => nil, 'limit' => 7},
               'canceled' => {'status' => nil, 'limit' => 7}
             }
           })
  
  menu(:top_menu,
       :kanban,
       {:controller => 'kanbans', :action => 'index'},
       :caption => :kanban_title,
       :if => Proc.new {
         User.current.allowed_to?(:view_kanban, nil, :global => true)
       })

  menu :admin_menu, :kanban_board_admin, { :controller => 'admin_kanban_boards', :action => 'index' }, :caption => :kanban_label_board_admin
end
