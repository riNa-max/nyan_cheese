class AddLineLinkToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :line_link_token, :string
    add_column :users, :line_link_token_generated_at, :datetime
  end
end
