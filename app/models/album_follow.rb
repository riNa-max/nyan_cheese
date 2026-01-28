class AlbumFollow < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  belongs_to :viewer, class_name: 'User'
  
  #重複フォローを防止するバリデーション
  validates :owner_id, uniqueness: { scope: :viewer_id }
end
