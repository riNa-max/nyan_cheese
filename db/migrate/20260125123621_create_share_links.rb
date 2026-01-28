class CreateShareLinks < ActiveRecord::Migration[6.1]
  def change
    create_table :share_links do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :token, null: false
      t.boolean :active , null: false, default: true

      t.timestamps
    end
    add_index :share_links, :token, unique: true
  end
end
