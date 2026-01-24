class AddLastRemindedAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :last_reminded_at, :datetime
  end
end
