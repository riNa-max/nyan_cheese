class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :photo, null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true
      t.boolean :read, null: false, default: false

      t.timestamps
    end

    add_index :notifications, [:user_id, :photo_id, :read]
  end
end
