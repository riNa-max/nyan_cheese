class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[line]

  has_many :photos, dependent: :destroy

  validates :remind_after_days, inclusion: { in: [3, 7] }

  def generate_line_link_token!
    self.line_link_token = SecureRandom.hex(4) 
    self.line_link_token_generated_at = Time.current
    save!
  end

  def clear_line_link_token!
    update!(line_link_token: nil, line_link_token_generated_at: nil)
  end
end
