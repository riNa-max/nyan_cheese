require "net/http"
require "json"
require "base64"
require "googleauth"

#Google Cloud Vision API を RESTで直接叩いて画像からラベル（タグ候補）を取得するクラス
class VisionRestTagger
  ENDPOINT = "https://vision.googleapis.com/v1/images:annotate".freeze
  SCOPE    = "https://www.googleapis.com/auth/cloud-platform".freeze

  MIN_SCORE  = 0.75
  MAX_LABELS = 10

  def initialize(photo)
    @photo = photo
  end

  def label_names
    raise "image not attached" unless @photo.image.attached?

    bytes  = @photo.image.download
    base64 = Base64.strict_encode64(bytes)

    body = {
      requests: [
        {
          image: { content: base64 },
          features: [{ type: "LABEL_DETECTION", maxResults: MAX_LABELS }]
        }
      ]
    }

    json = post_json(ENDPOINT, body)
    anns = json.dig("responses", 0, "labelAnnotations") || []

    anns.select { |a| a["score"].to_f >= MIN_SCORE }
        .map { |a| a["description"].to_s }
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
      raise "Vision API error: #{res.code} #{res.body}" unless res.is_a?(Net::HTTPSuccess)
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
