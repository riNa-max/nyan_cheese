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

    AutoTagPhotoJob.perform_later(photo_id: photo.id) 

    user.update!(last_photo_at: Time.current)

  end

  def handle_text_message(event)
    text           = event.dig("message", "text").to_s.strip
    source_user_id = event.dig("source", "userId")
    reply_token    = event["replyToken"]

    return if text.blank? || source_user_id.blank?

    # すでに連携済みか確認
    existing = User.find_by(line_user_id: source_user_id)
    if existing
      # 既に連携済みなら何もしない（必要なら案内だけ返す）
      # reply_line_message(reply_token, "✅ すでに連携済みです！") if reply_token.present?
      return
    end

    # 連携コードとして扱う（"連携 " があってもなくてもOK）
    token = text.sub(/^連携\s*/,"").strip
    if token.blank?
      reply_line_message(reply_token, "⚠️ アプリで表示された連携コードを送ってください") if reply_token.present?
      return
    end

    user = User.find_by(line_link_token: token)

    if user
      # ここで source_user_id を保存して Messaging API と紐付ける
      user.update!(
        line_user_id: source_user_id,
        line_link_token: nil,
        line_link_token_generated_at: nil
      )

      reply_line_message(
        reply_token,
        "✅ 連携完了しました！これから写真を送るとアルバムに保存されます。"
      ) if reply_token.present?
    else
      reply_line_message(
        reply_token,
        "⚠️ 連携コードが見つかりませんでした。\n\n" \
        "すでにアプリに登録している方は、連携画面でコードを確認してもう一度送ってください。\n" \
        "まだ登録していない方は、先にアプリ登録をお願いします。"
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
