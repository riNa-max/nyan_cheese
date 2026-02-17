class Tag < ApplicationRecord
  has_many :photo_tags, dependent: :destroy
  has_many :photos, through: :photo_tags
  #case_sensitive:大文字と小文字を区別するかどうか
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 30 }

  def display_name
    #name_ja があれば → 日本語表示、なければ → 英語の name
    name_ja.presence || name
  end
end
