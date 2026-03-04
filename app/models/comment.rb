class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :photo
  #validations:フォームから入力されたデータが正しいかどうかを検証する仕組み
  #presence:オブジェクトがnilまたは空でないことを検証
  validates :body, presence: true, length: { maximum: 500 }

  after_create :create_notifications_for_photo_owner

  private

  def create_notifications_for_photo_owner
    return if photo.user_id == user_id

    Notification.create!(
      user_id: photo.user_id,
      photo_id: photo.id,
      comment_id: id
    )
  end
end
