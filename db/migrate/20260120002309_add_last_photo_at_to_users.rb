class AddLastPhotoAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :last_photo_at, :datetime
  end
end
