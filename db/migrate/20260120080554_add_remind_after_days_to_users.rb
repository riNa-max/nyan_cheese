class AddRemindAfterDaysToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :remind_after_days, :integer, null: false, default: 3
  end
end
