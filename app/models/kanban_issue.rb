# A Kanban issue will Kanban specific information about an issue
# including it's state, position, and association.  #2607
class KanbanIssue < ActiveRecord::Base
  unloadable

  belongs_to :issue
  belongs_to :user
  belongs_to :kanban_board

  acts_as_list

  # For acts_as_list
  def scope_condition
    if user_id
      "state = #{connection.quote(state)} AND user_id = #{connection.quote(user_id)}"
    else
      "state = #{connection.quote(state)} AND user_id IS NULL"
    end
  end

  validates_presence_of :position
  validates_presence_of :kanban_board

  # States
  include AASM
  aasm_column :state
  aasm_initial_state :none

  aasm_state :none
  aasm_state :selected, :enter => :remove_user
  aasm_state :active
  aasm_state :testing

  aasm_event :selected do
    transitions :to => :selected, :from => [:none, :active, :testing]
  end

  aasm_event :active do
    transitions :to => :active, :from => [:none, :selected, :testing]
  end

  aasm_event :testing do
    transitions :to => :testing, :from => [:none, :selected, :active]
  end

  # Named with a find_ prefix because of the name conflict with the
  # state transitions.
  scope :find_selected, where(:user_id => nil, :state => 'selected').order("#{KanbanIssue.table_name}.position ASC")

  def self.find_active(user_id = 0)
    find_in_state('active', user_id)
  end

  def self.find_testing(user_id = 0)
    find_in_state('testing', user_id)
  end
  
  def remove_user
    self.user = nil
    save!
  end

  # Called when an issue is updated. This will create, remove, or
  # modify a KanbanIssue based on an Issue's status change
  def self.update_from_issue(issue)
    KanbanBoard.update_from_issue(issue)
  end

  private

  def self.find_in_state(state, user_id = 0)
    conditions = if user_id.zero?
      ['user_id = 0 OR user_id IS NULL']
    else
      ['user_id = ?', user_id]
    end

    self.where(conditions).where(['state = ?', state]).order("#{KanbanIssue.table_name}.user_id ASC, #{KanbanIssue.table_name}.position ASC")
  end
end
