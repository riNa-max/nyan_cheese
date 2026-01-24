class AddRemindEnabledToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :remind_enabled, :boolean,   default: true, null: false
  end
end
