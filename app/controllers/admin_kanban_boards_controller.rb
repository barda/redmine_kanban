class AdminKanbanBoardsController < ApplicationController
  unloadable

  layout 'admin'

  before_filter :require_admin

  def index
    @resources = KanbanBoard.order
  end

  def new
    @resource = KanbanBoard.new
  end

  def create
    @resource = KanbanBoard.new(params[:resource])

    if @resource.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to admin_kanban_boards_path
    else
      render :action => :new
    end
  end

  def edit
    @resource = KanbanBoard.find(params[:id])

    if @resource.nil?
      redirect_to admin_kanban_boards_path
    end
  end

  def update
    @resource = KanbanBoard.find(params[:id])
    @resource.update_attributes(params[:resource])

    if @resource.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to admin_kanban_boards_path
    else
      render :action => :edit
    end
  end

  def destroy
    @resource = KanbanBoard.find(params[:id])
    if @resource && @resource.destroy
      flash[:notice] = l(:notice_successful_delete)
    end
    redirect_to admin_kanban_boards_path
  end
end
