class KanbanPane::SelectedPane < KanbanPane
  def get_issues(options={})
    pane_issues.find_selected
  end
end
