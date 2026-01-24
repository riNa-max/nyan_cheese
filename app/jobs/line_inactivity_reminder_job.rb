class LineInactivityReminderJob < ApplicationJob
  queue_as :default

  def perform
    users = User.where.not(line_user_id: nil)
                .where(remind_enabled: true)
                .where("last_reminded_at IS NULL OR last_reminded_at < ?", 24.hours.ago)

    users.find_each do |user|
      days = user.remind_after_days || 3
      threshold = days.days.ago

      inactive =
        user.last_photo_at.nil? || user.last_photo_at < threshold

      next unless inactive

      response = LinePushClient.push_text(
        to: user.line_user_id,
        text: "にゃんチーズ🐾 ここ#{days}日ほど写真が届いてないよ〜！今日の1枚、送ってアルバムに残そ📸"
      )

      if response&.is_a?(Net::HTTPSuccess)
        user.update!(last_reminded_at: Time.current)
      else
        Rails.logger.warn("[REMIND NOT UPDATE] user_id=#{user.id} line_user_id=#{user.line_user_id}")
      end
    end
  end
end

