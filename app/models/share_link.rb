class ShareLink < ApplicationRecord
  belongs_to :owner, class_name: 'User'

  #レコードを作成する前にset_tokenメソッドを実行
  before_validation :set_token, on: :create

  #tokenが空でないこと、一意であることを検証
  validates :token, presence: true, uniqueness: true
  #boolean型のactive属性がtrueまたはfalseであることを検証
  validates :active, inclusion: { in: [true, false] }

  private

  #||=←すでにtokenがあれば何もしない。なければ生成
  def set_token
    self.token ||= SecureRandom.urlsafe_base64(16)
  end
end
