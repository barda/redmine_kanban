RedmineApp::Application.routes.draw do
  resources :kanbans do 
    put 'sync', :on => :member
  end

  resources :kanbaniterations do 
    put 'sync', :on => :member
  end

  resources :admin_kanban_boards, :controller => 'admin_kanban_boards', :path => 'admin/kanban_boards', :except => [:show]
end
