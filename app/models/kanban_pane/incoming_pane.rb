class KanbanPane::IncomingPane < KanbanPane
  def get_issues(options={})
    return [[]] if missing_settings('incoming')
    pane_settings = settings['panes']['incoming']    

    issues = Issue.visible
    issues = issues.limit(pane_settings['limit'].to_i)
    issues = issues.order("#{ISSUE_TABLE_NAME}.created_on ASC")
    issues = issues.where("#{ISSUE_TABLE_NAME}.status_id = ?", pane_settings['status'].to_i)

    issues
  end
end
