class AddIndexToUsersLineLink < ActiveRecord::Migration[6.1]
  def change
    add_index :users, :line_user_id, unique: true
    add_index :users, :line_link_token, unique: true
  end
end
