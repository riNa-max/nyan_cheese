class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[line]

  has_many :photos, dependent: :destroy

  validates :remind_after_days, inclusion: { in: [3, 7] }

  #share_linksテーブルはuser_idではなくowner_idで紐づいているため、foreign_keyオプションを指定
  has_many :share_links, foreign_key: :owner_id, dependent: :destroy

  #AlbumFollowはownerとviewerの2つのUser参照を持つため、別名で関連付けを定義（中間データ）
  #owner(自分のアルバムを見られる人)側の関連付け
  has_many :album_follows_as_owner, class_name: 'AlbumFollow', foreign_key: :owner_id, dependent: :destroy
  has_many :followers, through: :album_follows_as_owner, source: :viewer
  #viewer(他人のアルバムを見る人)側の関連付け
  has_many :album_follows_as_viewer, class_name: 'AlbumFollow', foreign_key: :viewer_id, dependent: :destroy
  has_many :following_owners, through: :album_follows_as_viewer, source: :owner

  def generate_line_link_token!
    self.line_link_token = SecureRandom.hex(4) 
    self.line_link_token_generated_at = Time.current
    save!
  end

  def clear_line_link_token!
    update!(line_link_token: nil, line_link_token_generated_at: nil)
  end
end
