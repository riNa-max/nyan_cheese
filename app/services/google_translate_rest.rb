require "net/http"
require "json"
require "googleauth"

#Google Cloud Translation API（v3）をRESTで直接叩いて翻訳するサービスクラス
class GoogleTranslateRest
  SCOPE = "https://www.googleapis.com/auth/cloud-platform".freeze

  def initialize(project_id:, location: "global")
    @project_id = project_id
    @location  = location
  end

  def translate_texts(texts, target: "ja", source: "en")
    #入力を整形
    texts = Array(texts).map(&:to_s).reject(&:empty?)
    return {} if texts.empty?

    #APIのURL生成
    url = "https://translation.googleapis.com/v3/projects/#{@project_id}/locations/#{@location}:translateText"

    body = {
      contents: texts,
      mimeType: "text/plain",
      sourceLanguageCode: source,
      targetLanguageCode: target
    }

    json = post_json(url, body)
    translations = json["translations"] || []

    result = {}
    texts.each_with_index do |t, i|
      result[t] = translations[i].to_h["translatedText"].to_s
    end
    result
  end

  private

  def post_json(url, payload)
    uri = URI(url)
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"]  = "application/json"
    req["Authorization"] = "Bearer #{access_token}"
    req.body = JSON.generate(payload)

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      res = http.request(req)
      raise "Translate API error: #{res.code} #{res.body}" unless res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    end
  end

  def access_token
    path = ENV["GOOGLE_APPLICATION_CREDENTIALS"]
    creds = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(path),
      scope: SCOPE
    )
    creds.fetch_access_token!
    creds.access_token
  end
end
