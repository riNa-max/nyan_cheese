require 'open3'
require 'json'

class VertexConnect
  attr_accessor :access_token, :uri
  
  def initialize
    project_id = ENV['VERTEX_PROJECT_ID']
    endpoint_id = ENV['VERTEX_ENDPOINT_ID']
    self.uri = "https://us-central1-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/us-central1/endpoints/#{endpoint_id}:predict"
    set_access_token
  end

  def get_tag(image_data)
    image_64 = Base64.strict_encode64(image_data)
    #判別画像に必要なJSONファイルの中身を作って
    input_data_json =
      <<~EOS
        {
          "instances": [{
            "content": "#{image_64}"
          }],
          "parameters": {
            "confidenceThreshold": 0.5,
            "maxPredictions": 5
          }
        }
      EOS

    #ファイルパスをtmpに指定
    input_data_file = "tmp/input_data.json"
    #ファイルの書き込み
    file = File.open(input_data_file, "w") { |f| f.puts(input_data_json) }
    
    #リクエスト
    result, stdout, stderr = Open3.capture3("curl -X POST -H 'Authorization: Bearer #{access_token}' -H 'Content-Type: application/json' '#{uri}' -d '@#{input_data_file}'")
    #レスポンスをHashに変換

    #tmpファイルは削除
    File.delete(input_data_file)

    #結果からタグを配列で抽出
    data = JSON.parse(result, symbolize_names: true)
    p tags = data[:predictions][0][:displayNames]
  end

  private

  def set_access_token
    self.access_token = `gcloud auth print-access-token`.chomp
    #APIへのログイン認証
    if access_token
      account = ENV['VERTEX_ACCOUNT']
      keyfile = ENV['VERTEX_KEYFILE']
      project_name = ENV['VERTEX_PROJECT_NAME']
      auth_command = "gcloud auth activate-service-account #{account} --key-file #{keyfile} --project #{project_name}"
      `#{auth_command}`
      #アクセストークンの再取得
      self.access_token = `gcloud auth print-access-token`.chomp
    end
  end
end