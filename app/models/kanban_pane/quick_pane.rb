class KanbanPane::QuickPane < KanbanPane
  def get_issues(options={})
    return [[]] if missing_settings('quick', :skip_status => true) || missing_settings('backlog')

    pane_settings = settings['panes']['quick']

    issues = Issue.visible
    issues = issues.limit(pane_settings['limit'].to_i)
    issues = issues.order("#{RedmineKanban::KanbanCompatibility::IssuePriority.klass.table_name}.position ASC, #{ISSUE_TABLE_NAME}.created_on ASC")
    issues = issues.includes(:priority)
    issues = issues.where("#{ISSUE_TABLE_NAME}.status_id = ? AND estimated_hours IS NULL", pane_settings['status'].to_i)

    return group_by_priority_position(issues)
  end

  protected

  # QuickPane uses different configuration logic since it requires the
  # backlog pane and doesn't have it's own status
  def self.configured?
     KanbanPane::BacklogPane.configured? &&
       settings['panes']['quick']['limit'].present? &&
       settings['panes']['quick']['limit'].to_i > 0
   end
end
