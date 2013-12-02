class KanbanPane
  attr_accessor :kanban

  ISSUE_TABLE_NAME = Issue.table_name
  DEFAULT_DAY_LIMIT = 7

  def initialize(kanban)
    self.kanban = kanban
  end

  def settings
    self.kanban.settings_by_pane
  end

  def pane_issues
    kanban.board.kanban_issues
  end

  def get_issues(options={})
    raise NotImplementedError
  end

  def pane_name
    self.class.name.demodulize.gsub(/pane/i, '').downcase
  end

  def configured?
    pane = pane_name
    (settings['panes'] && settings['panes'][pane] && !settings['panes'][pane]['status'].blank?)
  end

  private

  def missing_settings(pane, options={})
    skip_status = options.delete(:skip_status)

    settings.blank? ||
      settings['panes'].blank? ||
      settings['panes'][pane].blank? ||
      settings['panes'][pane]['limit'].blank? ||
      (settings['panes'][pane]['status'].blank? && !skip_status)
  end

  # Sort and group a set of issues based on IssuePriority#position
  def group_by_priority_position(issues)
    return issues.group_by {|issue|
      issue.priority
    }.sort {|a,b|
      a[0].position <=> b[0].position
    }
  end
end
