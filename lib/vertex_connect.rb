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

  def get_tag
   #判別画像のファイルパス
    input_data_file = 'lib/cat.json'
    #リクエスト
    result, stdout, stderr = Open3.capture3("curl -X POST -H 'Authorization: Bearer #{access_token}' -H 'Content-Type: application/json' '#{uri}' -d '@#{input_data_file}'")
    #レスポンスをHashに変換
    data = JSON.parse(result, symbolize_names: true)
    p tags = data[:predictions][0][:displayNames]
  end

  private

  def set_access_token
    self.access_token = `gcloud auth print-access-token`.chomp
    #APIへのログイン認証
    if !access_token.present?
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