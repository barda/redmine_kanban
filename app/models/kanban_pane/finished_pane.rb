class KanbanPane::FinishedPane < KanbanPane
  def get_issues(options={})
    return [[]] if missing_settings('finished')

    pane_settings = settings['panes']['finished']

    days = pane_settings['limit'].to_i || KanbanPane::DEFAULT_DAY_LIMIT

    issues = Issue.visible
    issues = issues.includes(:assigned_to)
    issues = issues.order("#{ISSUE_TABLE_NAME}.updated_on DESC")
    issues = issues.where("#{ISSUE_TABLE_NAME}.status_id = ? AND #{ISSUE_TABLE_NAME}.updated_on > ?", pane_settings['status'].to_i, days.to_f.days.ago)

    issues.group_by(&:assigned_to)
  end
end
