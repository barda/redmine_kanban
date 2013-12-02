class Kanban
  attr_accessor :incoming_pane, :backlog_pane, :quick_pane, :canceled_pane, :finished_pane, :active_pane, :testing_pane, :selected_pane
  
  attr_accessor :board
  attr_accessor :incoming_issues
  attr_accessor :quick_issues
  attr_accessor :backlog_issues
  attr_accessor :selected_issues
  attr_accessor :active_issues
  attr_accessor :testing_issues
  attr_accessor :finished_issues
  attr_accessor :canceled_issues
  attr_accessor :settings
  attr_accessor :users

  def initialize(board)
    self.board = board

    @incoming_pane = KanbanPane::IncomingPane.new(self)
    @backlog_pane = KanbanPane::BacklogPane.new(self)
    @quick_pane = KanbanPane::QuickPane.new(self)
    @canceled_pane = KanbanPane::CanceledPane.new(self)
    @finished_pane = KanbanPane::FinishedPane.new(self)
    @active_pane = KanbanPane::ActivePane.new(self)
    @testing_pane = KanbanPane::TestingPane.new(self)
    @selected_pane = KanbanPane::SelectedPane.new(self)
    
    @settings = settings_by_pane
    @users = get_users
  end

  def self.non_kanban_issues_panes
     ["incoming","backlog", "quick","finished","canceled"]
  end

  def self.kanban_issues_panes
    ['selected','active','testing']
  end

  def self.valid_panes
    kanban_issues_panes + non_kanban_issues_panes
  end

  def self.staffed_panes
    ['active','testing','finished','canceled']
  end

  def settings_by_pane
    if @settings_by_pane.nil?
      @settings_by_pane = {
        'panes' => {
          'incoming' => {
            'status' => self.board.pane_incoming_issue_status,
            'limit' => self.board.pane_incoming_size
          },
          'backlog' => {
            'status' => self.board.pane_backlog_issue_status,
            'limit' => self.board.pane_backlog_size
          },
          'quick' => {
            'status' => self.board.pane_quick_issue_status,
            'limit' => self.board.pane_quick_size
          },
          'selected' => {
            'status' => self.board.pane_selected_issue_status,
            'limit' => self.board.pane_selected_size
          },
          'active' => {
            'status' => self.board.pane_active_issue_status,
            'limit' => self.board.pane_active_size
          },
          'testing' => {
            'status' => self.board.pane_testing_issue_status,
            'limit' => self.board.pane_testing_size
          },
          'finished' => {
            'status' => self.board.pane_finished_issue_status,
            'limit' => self.board.pane_finished_size
          },
          'canceled' => {
            'status' => self.board.pane_canceled_issue_status,
            'limit' => self.board.pane_canceled_size
          }
        },
        'staff_role' => self.board.staff_role.to_i
      }
    end

    @settings_by_pane
  end

  def incoming_issues
    @incoming_issues ||= incoming_pane.get_issues
  end

  def quick_issues
    @quick_issues ||= quick_pane.get_issues
  end

  def backlog_issues
    quick_issues # Needs to load quick_issues
    @backlog_issues ||= backlog_pane.get_issues(:exclude_ids => quick_issue_ids)
  end

  def selected_issues
    @selected_issues ||= selected_pane.get_issues
  end

  def active_issues
    @active_issues ||= active_pane.get_issues(:users => get_users)
  end

  def testing_issues
    @testing_issues ||= testing_pane.get_issues(:users => get_users)
  end

  def finished_issues
    @finished_issues ||= finished_pane.get_issues
  end

  def canceled_issues
    @canceled_issues ||= canceled_pane.get_issues
  end

  def get_users
    role = Role.find_by_id(@settings["staff_role"].to_i)
    @users = role.members.collect(&:user).uniq.compact.sort if role
    @users ||= []
    @users = move_current_user_to_front
    #@users << UnknownUser.instance
    @users
  end
  
  def quick_issue_ids
    if quick_issues.present?
      quick_issues.collect {|ary| ary[1] }.flatten.collect(&:id)
    else
      []
    end
  end

  # Updates +target_pane+ so that the KanbanIssues match +sorted_issues+
  def update_sorted_issues(target_pane, sorted_issues, user_id=nil)
    if Kanban.kanban_issues_panes.include?(target_pane)
      if sorted_issues.blank? && !target_pane.blank?
        self.board.kanban_issues.destroy_all(:state => target_pane, :user_id => user_id)
      else
        # Remove items that are in the database but not in the sorted_issues
        if user_id
          self.board.kanban_issues.where(['state = ? AND user_id = ? AND issue_id NOT IN (?)', target_pane, user_id, sorted_issues]).map(&:destroy)
        else
          self.board.kanban_issues.where(['state = ? AND issue_id NOT IN (?)', target_pane, sorted_issues]).map(&:destroy)
        end
          
        sorted_issues.each_with_index do |issue_id, zero_position|
          kanban_issue = self.board.kanban_issues.find_by_issue_id(issue_id)
          if kanban_issue
            if kanban_issue.state != target_pane
              # Change state
              kanban_issue.send(target_pane.to_sym)
            end
            kanban_issue.user_id = user_id unless target_pane == 'selected'
            kanban_issue.position = zero_position + 1 # acts_as_list is 1 based
            kanban_issue.save
          else
            kanban_issue = self.board.kanban_issues.new
            kanban_issue.issue_id = issue_id
            kanban_issue.state = target_pane
            kanban_issue.user_id = user_id unless target_pane == 'selected'
            kanban_issue.position = (zero_position + 1)
            kanban_issue.save
            # Need to resave since acts_as_list automatically moves a
            # new issue to the bottom on create
            kanban_issue.insert_at(zero_position + 1)
          end
        end
      end
    end
  end

  # Updates the Issue with +issue_id+ to change it's
  # - status to the IssueStatus set for the +to+ pane
  # - assignment to the +target_user+ on staffed panes
  def update_issue_attributes(issue_id, from, to, updating_user, target_user=nil)
    issue = Issue.find_by_id(issue_id)

    pane_settings = @settings['panes'][to]
    if pane_settings && pane_settings['status']
      new_status = IssueStatus.find_by_id(pane_settings['status'].to_i)
    end
      
    if issue && new_status
      issue.init_journal(updating_user)
      issue.status = new_status

      if Kanban.staffed_panes.include?(to) && !target_user.nil? && target_user.is_a?(User)
        issue.assigned_to = target_user
      end

      issue.save
    else
      false
    end
  end

  private

  def move_current_user_to_front
    if user = @users.delete(User.current)
      @users.unshift(user)
    else
      @users
    end
  end
end
