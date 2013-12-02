module KanbansHelper
  def name_to_css(name)
    name.gsub(' ','-').downcase
  end

  def render_pane_to_js(pane, user=nil)
    if Kanban.valid_panes.include?(pane)
	    return render_to_string(:partial => pane, :locals => {:user => user })
    else
      ''
    end
  end

  # Returns the CSS class for jQuery to hook into.  Current users are
  # allowed to Drag and Drop items into their own list, but not other
  # people's lists
  def allowed_to_assign_staffed_issue_to(user)
    if allowed_to_manage? || User.current == user
      'allowed'
    else
      ''
    end
  end

  def over_pane_limit?(limit, counter)
    if !counter.nil? && !limit.nil? && counter.to_i >= limit.to_i # 0 based counter
      return 'over-limit'
    else
      return ''
    end
  end

  # Was the last journal with a note created by someone other than the
  # assigned to user?
  def updated_note_on_issue?(issue)
    if issue && issue.journals.present?
      last_journal_with_note = issue.journals.select {|journal| journal.notes.present?}.last
      last_journal_with_note && issue.assigned_to_id != last_journal_with_note.user_id
    end
  end

  def kanban_issue_css_classes(issue)
    css = 'kanban-issue ' + issue.css_classes
    if User.current.logged? && !issue.assigned_to_id.nil? && issue.assigned_to_id != User.current.id
      css << ' assigned-to-other'
    end
    css << ' issue-behind-schedule' if issue.behind_schedule?
    css << ' issue-overdue' if issue.overdue?
    css
  end

  def issue_icon_link(issue)
    if Setting.gravatar_enabled? && issue.assigned_to
      img = avatar(issue.assigned_to, {
        :class => 'gravatar icon-gravatar',
        :size => 10,
        :title => l(:field_assigned_to) + ": " + issue.assigned_to.name
      })
      link_to(img, :controller => 'issues', :action => 'show', :id => issue)
    else
      link_to(image_tag('ticket.png', :style => 'float:left;'), :controller => 'issues', :action => 'show', :id => issue)
    end
  end

  def column_configured?(kanban, column)
    case column
    when :unstaffed
      kanban.incoming_pane.configured? || kanban.backlog_pane.configured?
    when :selected
      kanban.quick_pane.configured? || kanban.selected_pane.configured?
    when :staffed
      true # always
    end
  end

  # Calculates the width of the column.  Max of 96 since they need
  # some extra for the borders.
  def column_width(kanban, column)
    # weights of the columns
    column_ratios = {
      :unstaffed => 1,
      :selected => 1,
      :staffed => 6
    }
    return 0.0 if column == :unstaffed && !column_configured?(kanban, :unstaffed)
    return 0.0 if column == :selected && !column_configured?(kanban, :selected)
    
    visible = 0
    visible += column_ratios[:unstaffed] if column_configured?(kanban, :unstaffed)
    visible += column_ratios[:selected] if column_configured?(kanban, :selected)
    visible += column_ratios[:staffed] if column_configured?(kanban, :staffed)
    
    return ((column_ratios[column].to_f / visible) * 96).round(2)
  end

  # Calculates the width of the column.  Max of 96 since they need
  # some extra for the borders.
  def staffed_column_width(kanban, column)
    # weights of the columns
    column_ratios = {
      :user => 1,
      :active => 1.25,
      :testing => 2,
      :finished => 2,
      :canceled => 2
    }
    return 0.0 if column == :active && !kanban.active_pane.configured?
    return 0.0 if column == :testing && !kanban.testing_pane.configured?
    return 0.0 if column == :finished && !kanban.finished_pane.configured?
    return 0.0 if column == :canceled && !kanban.canceled_pane.configured?

    visible = 0
    visible += column_ratios[:user]
    visible += column_ratios[:active] if kanban.active_pane.configured?
    visible += column_ratios[:testing] if kanban.testing_pane.configured?
    visible += column_ratios[:finished] if kanban.finished_pane.configured?
    visible += column_ratios[:canceled] if kanban.canceled_pane.configured?
    
    return ((column_ratios[column].to_f / visible) * 96).round(2)
  end

  def render_priority_for_issue(issue)
    return "" unless issue.priority
    raw("<br/><span style='color:blue'> Priority: #{h(issue.priority.name)}</span>\n")
  end

  def render_custom_field_developer_for_kanban(issue)
    return if issue.custom_field_values.empty?
    s = ""
    #value = issue.custom_field_values.select{|item| item.custom_field.name == 'Developer'}.last	
    value = issue.custom_value_for(40)
    return "" unless value
    return "" unless value.value
    if !value.value.blank?
    	s << "<br/><span style='color:green;font-weight:bolder'> #{ h(value.custom_field.name) }: #{ simple_format_without_paragraph(h(show_value(value))) }</span>\n"
    end
   raw(s)
  end
	    
  # Return a string used to display a custom value
  def show_value(custom_value)
    return "" unless custom_value
    format_value(custom_value.value, custom_value.custom_field.field_format)
  end

  # Return a string used to display a custom value
  def format_value(value, field_format)
    Redmine::CustomFieldFormat.format_value(value, field_format) # Proxy
  end
  
  def issue_url(issue)
    url_for(:controller => 'issues', :action => 'show', :id => issue)
  end
end
