class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :user_id
      t.integer :sender_id
      t.integer :recipient_id
      t.integer :subject_id
      t.string :subject
      t.text :content
      t.boolean :opened, :default => false
      t.boolean :deleted, :default => false
      t.boolean :copies, :default => false
      t.string :ancestry
      t.timestamps
    end

    add_index :messages, [:user_id, :subject_id, :ancestry], :name => "messages_idx"
  end

  def self.down
    drop_index :messages, "messages_idx"
    drop_table :messages
  end
end
