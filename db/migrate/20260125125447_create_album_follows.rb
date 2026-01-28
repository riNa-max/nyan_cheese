class CreateAlbumFollows < ActiveRecord::Migration[6.1]
  def change
    create_table :album_follows do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.references :viewer, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :album_follows, [:owner_id, :viewer_id], unique: true
  end
end
