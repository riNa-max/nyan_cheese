class AddNameJaToTags < ActiveRecord::Migration[6.1]
  def change
    add_column :tags, :name_ja, :string
    add_index :tags, :name_ja
  end
end
