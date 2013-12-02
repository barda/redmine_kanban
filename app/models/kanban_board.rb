class KanbanBoard < ActiveRecord::Base
  unloadable

  has_many :kanban_issues, :dependent => :destroy

  serialize :settings

  validates_presence_of :name
  validates_uniqueness_of :name

  attr_accessible :name

  def self.update_from_issue(issue)
    KanbanBoard.find_each do |board|
      board.update_from_issue(issue)
    end
  end

  def update_from_issue(issue)
    return true if issue.nil?

    if configured_statuses.include?(issue.status_id)
      kanban_issue = KanbanIssue.find_or_initialize_by_issue_id_and_kanban_board_id(issue.id, self.id)
      
      kanban_issue.state = pane_for_status(issue.status_id)

      if kanban_issue.new_record?
        kanban_issue.position = 0
      end

      if ['active','testing'].include?(kanban_issue.state)
        # TODO: Possible to create KanbanIssue with a null user if the
        # Issue has no user assigned and is moved to a staffed pane manually
	      kanban_issue.user = issue.assigned_to #unless issue.assigned_to.nil?
      end
      
      return kanban_issue.save
    else
      KanbanIssue.destroy_all(['issue_id = ?', issue.id])
    end

    true
  end

private
  def configured_statuses
    valid_statuses = []
    status_to_pane_map.each do |issue_status_id, current_status_panes|
      if Kanban.kanban_issues_panes.any?{|valid_pane| current_status_panes.include?(valid_pane)}
        valid_statuses << issue_status_id
      end
    end

    valid_statuses
  end

  # { IssueStatus.id => KanbanPaneName }
  def status_to_pane_map
    if @status_to_pane_map.nil?
      rv = {}
      issue_status_ids.each do |issue_status_id|
        rv[issue_status_id] = [] if !rv.has_key?(issue_status_id)
        pane = pane_for_status(issue_status_id)
        rv[issue_status_id] << pane
      end

      @status_to_pane_map = rv
    end

    @status_to_pane_map
  end

public
  def pane_for_status(status_id)
    case status_id
    when pane_incoming_issue_status.to_i
      'incoming'
    when pane_backlog_issue_status.to_i
      'backlog'
    when pane_quick_issue_status.to_i
      'quick'
    when pane_selected_issue_status.to_i
      'selected'
    when pane_active_issue_status.to_i
      'active'
    when pane_testing_issue_status.to_i
      'testing'
    when pane_finished_issue_status.to_i
      'finished'
    when pane_canceled_issue_status.to_i
      'canceled'
    end
  end

  def issue_status_ids
    [pane_incoming_issue_status.to_i, pane_backlog_issue_status.to_i, pane_quick_issue_status.to_i, pane_selected_issue_status.to_i, pane_active_issue_status.to_i, pane_testing_issue_status.to_i, pane_finished_issue_status.to_i, pane_canceled_issue_status.to_i].compact.uniq
  end

  def to_label
    name
  end

  def self.serialized_attr_accessor(*args)
    args.each do |method_name|
      eval "
        def #{method_name}
          (self.settings || {})[:#{method_name}]
        end
        def #{method_name}=(value)
          self.settings ||= {}
          self.settings[:#{method_name}] = value
        end
        attr_accessible :#{method_name}
      "
    end
  end

  serialized_attr_accessor :staff_role,
    :pane_incoming_issue_status, :pane_incoming_size,
    :pane_backlog_issue_status, :pane_backlog_size,
    :pane_quick_issue_status, :pane_quick_size,
    :pane_selected_issue_status, :pane_selected_size,
    :pane_active_issue_status, :pane_active_size,
    :pane_testing_issue_status, :pane_testing_size,
    :pane_finished_issue_status, :pane_finished_size,
    :pane_canceled_issue_status, :pane_canceled_size
end
