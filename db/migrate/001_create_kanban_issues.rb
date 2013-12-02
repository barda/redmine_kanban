class CreateKanbanIssues < ActiveRecord::Migration
  def change
    create_table :kanban_issues do |t|
      t.references :user
      t.integer :position
      t.references :issue
      t.string :state
    end

    add_index :kanban_issues, :user_id
    add_index :kanban_issues, :issue_id
    add_index :kanban_issues, :state
  end
end
