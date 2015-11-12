class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.integer :meeting_id
      t.text :message
      t.integer :user_id
      t.integer :expression_id
      t.integer :datetime

      t.timestamps
    end
  end
end