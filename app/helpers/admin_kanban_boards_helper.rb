module AdminKanbanBoardsHelper
  def staff_role_select(f, board)
    rv = f.label(:staff_role)

    selected = (board && board.settings && board.settings[:staff_role]) ? board.settings[:staff_role].to_i : 0
    rv += select_tag('resource[staff_role]',
          content_tag(:option, '') + options_from_collection_for_select(Role.all, :id, :name, selected),
          { :required => false }
    )

    rv
  end

  def pane_issue_status_select_for_open_issues(f, board, pane_name, html_opts = {})
    var_name = "pane_#{pane_name}_issue_status".to_sym

    rv = f.label(var_name)

    selected = board && board.settings && board.settings[var_name] ? board.settings[var_name].to_i : 0
    rv += select_tag("resource[#{var_name}]",
      content_tag(:option, '') + options_from_collection_for_select(IssueStatus.all, :id, :name, selected), html_opts)

    rv
  end

  def pane_issue_status_select_for_closed_issues(f, board, pane_name)
    var_name = "pane_#{pane_name}_issue_status".to_sym

    rv = f.label(var_name)

    selected = board && board.settings && board.settings[var_name] ? board.settings[var_name].to_i : 0
    rv += select_tag("resource[#{var_name}]",
      content_tag(:option, '') +
      options_from_collection_for_select(IssueStatus.all(:conditions => {:is_closed => true}), :id, :name, selected),
      { :required => true }
    )

    rv
  end
end
