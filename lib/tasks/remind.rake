namespace :remind do
  desc "Send inactivity reminders to users via LINE"
  task send: :environment do
    LineInactivityReminderJob.perform_later
  end
end