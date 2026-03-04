class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :photo
  belongs_to :comment

  scope :unread, -> { where(read: false) }
end
