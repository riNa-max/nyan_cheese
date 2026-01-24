require "net/http"
require "json"

class LinePushClient
  PUSH_URL = "https://api.line.me/v2/bot/message/push"

  def self.push_text(to:, text:)
    return nil if to.blank? || text.blank?

    uri = URI(PUSH_URL)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req["Authorization"] = "Bearer #{ENV['LINE_CHANNEL_ACCESS_TOKEN']}"

    req.body = {
      to: to,
      messages: [{ type: "text", text: text }]
    }.to_json

    res = http.request(req)

    unless res.is_a?(Net::HTTPSuccess)
      Rails.logger.error("LINE push failed: status=#{res.code} body=#{res.body}")
    end

    res

  rescue => e
    Rails.logger.error("LINE push error: #{e.class} #{e.message}")
    nil

  end
end
