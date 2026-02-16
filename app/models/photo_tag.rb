class PhotoTag < ApplicationRecord
  belongs_to :photo
  belongs_to :tag

  #重複タグ付けを防止するバリデーション
  validates :photo_id, uniqueness: { scope: :tag_id }
end
