class CreateMeetings < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.string :name
      t.string :description
      t.integer :status
      t.integer :master_user_id

      t.timestamps
    end
    
    add_index :meetings, :master_user_id
  end
end