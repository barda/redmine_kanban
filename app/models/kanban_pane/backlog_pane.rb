class KanbanPane::BacklogPane < KanbanPane
  def get_issues(options={})
    return [[]] if missing_settings('backlog')

    pane_settings = settings['panes']['backlog']

    exclude_ids = options.delete(:exclude_ids)

    issues = Issue.visible
    issues = issues.limit(pane_settings['limit'])
    issues = issues.order("#{RedmineKanban::KanbanCompatibility::IssuePriority.klass.table_name}.position ASC, #{ISSUE_TABLE_NAME}.created_on ASC")
    issues = issues.includes(:priority)
    issues = issues.where("#{ISSUE_TABLE_NAME}.status_id IN (?)", pane_settings['status'])
    issues = issues.where("#{ISSUE_TABLE_NAME}.id NOT IN (?)", exclude_ids) unless exclude_ids.empty?

    return group_by_priority_position(issues)
  end
end
