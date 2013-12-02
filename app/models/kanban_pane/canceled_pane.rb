class KanbanPane::CanceledPane < KanbanPane
  def get_issues(options={})
    return [[]] if missing_settings('canceled')

    pane_settings = settings['panes']['canceled']

    days = pane_settings['limit'].to_i || KanbanPane::DEFAULT_DAY_LIMIT

    issues = Issue.visible
    issues = issues.includes(:assigned_to)
    issues = issues.order("#{ISSUE_TABLE_NAME}.updated_on DESC")
    issues = issues.where("#{ISSUE_TABLE_NAME}.status_id = ? AND #{ISSUE_TABLE_NAME}.updated_on > ?", pane_settings['status'].to_i, days.to_f.days.ago)

    return issues.group_by(&:assigned_to)
  end
end
