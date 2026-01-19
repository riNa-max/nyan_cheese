class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def line
    body = request.body.read
    events = JSON.parse(body)["events"] || []

    events.each do |event|
      next unless event["type"] == "message"

      message_type = event.dig("message", "type")

      case message_type
      when "image"
        handle_image_message(event)
      when "text"
        handle_text_message(event)
      end
    end

    head :ok
  end

  private

  # ----------------------------
  # 画像メッセージ：画像を取得して保存
  # 連携済みユーザー（line_user_idが一致）にだけ保存する
  # ----------------------------
  def handle_image_message(event)
    message_id      = event.dig("message", "id")
    source_user_id  = event.dig("source", "userId")
    reply_token     = event["replyToken"]

    return if message_id.blank? || source_user_id.blank?

    user = User.find_by(line_user_id: source_user_id)

    unless user
      if reply_token.present?
        reply_line_message(
          reply_token,
          "⚠️ まだアプリとLINEが連携されていません。\n" \
          "1) アプリにログイン\n" \
          "2) LINE友だち追加 → 連携コード送信\n" \
          "が完了すると、写真がアルバムに保存されるようになります。"
        )
      end
      return
    end

    image_data = fetch_line_image(message_id)

    photo = user.photos.create!
    photo.image.attach(
      io: StringIO.new(image_data),
      filename: "line_#{message_id}.jpg",
      content_type: "image/jpeg"
    )
  end
  # ----------------------------
  # メッセージ：送付されたメッセージが連携コードかどうか判定
  # 未連携ユーザーの場合、連携する旨をLINEでリプする
  # ----------------------------
def handle_text_message(event)
  text           = event.dig("message", "text").to_s.strip
  source_user_id = event.dig("source", "userId")
  reply_token    = event["replyToken"]

  return if text.blank? || source_user_id.blank?

  user = User.find_by(line_user_id: source_user_id)

  unless user
    token = text.sub(/^連携\s*/,"").strip
    linked_user = User.find_by(line_link_token: token)

    if linked_user
      linked_user.update!(line_user_id: source_user_id)
      reply_line_message(reply_token, "✅ 連携完了しました！") if reply_token.present?
    else
      reply_line_message(reply_token, "⚠️ アプリとLINEを連携してください") if reply_token.present?
    end
    return
  end

end

  # ----------------------------
  # テキストメッセージ：連携コードを受け取って紐付け
  # 例: "連携 a3f09c1d" or "a3f09c1d"
  # ----------------------------
  def handle_text_message(event)
    text           = event.dig("message", "text").to_s.strip
    source_user_id = event.dig("source", "userId")
    reply_token    = event["replyToken"]

    return if text.blank? || source_user_id.blank?

    token = text.sub(/^連携\s*/,"").strip
    return if token.blank?

    user = User.find_by(line_link_token: token)

    if user
      user.update!(line_user_id: source_user_id)
      user.update!(line_link_token: nil, line_link_token_generated_at: nil)

      reply_line_message(reply_token, "✅ 連携完了しました！これから写真を送るとアルバムに保存されます。") if reply_token.present?
    else
      reply_line_message(
        reply_token,
          "⚠️ 連携コードが見つかりませんでした。\n\n" \
          "すでにアプリに登録している方は、連携画面でコードを確認してもう一度送ってください。\n" \
          "まだ登録していない方は、先にアプリ登録をお願いします。\n\n" \
          "登録後、連携コードを送ると写真が保存されるようになります。"
      ) if reply_token.present?
    end
  end


  # ----------------------------
  # LINE APIから画像バイナリ取得
  # 失敗時はログに残して例外を投げる（原因が見える）
  # ----------------------------
  def fetch_line_image(message_id)
    uri = URI("https://api-data.line.me/v2/bot/message/#{message_id}/content")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{ENV['LINE_CHANNEL_ACCESS_TOKEN']}"

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("LINE content fetch failed: status=#{response.code} body=#{response.body}")
      raise "LINE content fetch failed: #{response.code}"
    end

    response.body
  end

  def reply_line_message(reply_token, message)
    uri = URI("https://api.line.me/v2/bot/message/reply")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{ENV['LINE_CHANNEL_ACCESS_TOKEN']}"

    request.body = {
      replyToken: reply_token,
      messages: [{ type: "text", text: message }]
    }.to_json

    http.request(request)
  end

end
