class KanbanPane::ActivePane < KanbanPane
  def get_issues(options={})
    users = options.delete(:users)

    users.inject({}) do |result, user|
      result[user] = pane_issues.find_active(user.id)
      result
    end
  end
end
