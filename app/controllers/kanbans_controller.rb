class KanbansController < ApplicationController
  unloadable
  helper :kanbans
  include KanbansHelper

  before_filter :authorize
  before_filter :setup_board, :only => [:show, :update]

  def index
    @resources = KanbanBoard.order
  end

  def show
    render 'kanbans/show'
  end

  def update
    load_user_and_user_id

    src_pane = params[:from]
    dst_pane = params[:to]
    src_issue = params[:issue_id]
    issues_requested_on_dst_pane = params[:to_issue]
    updating_user = User.current

    # src_pane = "incoming"
    # dst_pane = "finished"
    # src_issue = 3
    # issues_requested_on_dst_pane = ["3", "4"]
    # @to_user_id = 9
    # @to_user = #<User id: 9, login: "developmentteam1" ...
    # @from_user = nil

    saved = @kanban.update_issue_attributes(issues_requested_on_dst_pane, src_pane, dst_pane, updating_user, @to_user)

    if Kanban.kanban_issues_panes.include?(dst_pane)
      @kanban.update_sorted_issues(dst_pane, issues_requested_on_dst_pane, @to_user_id)
    end
	
    respond_to do |format|
      if saved 
        format.html {
	        flash[:notice] = l(:kanban_text_saved)
          redirect_to kanban_path
        }
        format.js {
          render :text => ActiveSupport::JSON.encode({
             'from' => render_pane_to_js(src_pane, @from_user),
             'to' => render_pane_to_js(dst_pane, @to_user),
             'additional_pane' => render_pane_to_js(params[:additional_pane])
           })
        	}
      else
        format.html {
          flash[:error] = l(:kanban_text_error_saving)
          redirect_to kanban_path
        }
        format.js { 
          render({:text => ({}.to_json), :status => :bad_request})
        }
      end
    end
  end

  def sync
    Issue.sync_with_kanban
    
    respond_to do |format|
      format.html {
        flash[:notice] = l(:kanban_text_notice_sync)
        redirect_to kanban_path
      }
    end
  end

  protected
  # Override the default authorize and add in the global option. This will allow
  # the user in if they have any roles with the correct permission
  def authorize(ctrl = params[:controller], action = params[:action])
    allowed = User.current.allowed_to?({:controller => ctrl, :action => action}, nil, { :global => true})
    allowed ? true : deny_access
  end

  helper_method :allowed_to_edit?
  def allowed_to_edit?
    User.current.allowed_to?({:controller => params[:controller], :action => 'update'}, nil, :global => true)
  end

  helper_method :allowed_to_manage?
  def allowed_to_manage?
    User.current.allowed_to?(:manage_kanban, nil, :global => true)
  end

  # Sets instance variables based on the parameters
  # * @from_user_id
  # * @from_user
  # * @to_user_id
  # * @to_user
  def load_user_and_user_id
    @from_user_id, @from_user = *extract_user_id_and_user(params[:from_user_id])
    @to_user_id, @to_user = *extract_user_id_and_user(params[:to_user_id])
  end

  def extract_user_id_and_user(user_id_param)
    user_id = nil
    user = nil

    case user_id_param
    when 'null' # Javascript nulls
      user_id = nil
      user = nil
    when '0' # Unknown user
      user_id = 0
      user = UnknownUser.instance
    else
      user_id = user_id_param
      user = User.find_by_id(user_id) # only needed for user specific views
    end

    return [user_id, user]
  end

  def setup_board
    @board = KanbanBoard.find(params[:id])

    if @board.nil?
      redirect_to kanbans_path
    end

    @kanban = Kanban.new(@board)
    @settings = @board.settings
  end
end
