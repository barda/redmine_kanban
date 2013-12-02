class CreateKanbanBoards < ActiveRecord::Migration
  def change
    create_table :kanban_boards do |t|
      t.string :name, :null => false
      t.text :settings
    end
    
    add_index :kanban_boards, :name, :unique => true

    add_column :kanban_issues, :kanban_board_id, :integer
    add_index :kanban_issues, :kanban_board_id
  end
end
