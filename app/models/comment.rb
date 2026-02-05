class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :photo
  #validations:フォームから入力されたデータが正しいかどうかを検証する仕組み
  #presence:オブジェクトがnilまたは空でないことを検証
  validates :body, presence: true, length: { maximum: 500 }
end
