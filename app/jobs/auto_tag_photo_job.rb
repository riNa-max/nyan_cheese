class AutoTagPhotoJob < ApplicationJob
  queue_as :default

  #ActiveJobではIDを渡して中で再取得する
  def perform(photo_id:)
    photo = Photo.find(photo_id)

    #ActiveStorageで画像が添付されていなければ終了
    return unless photo.image.attached?

    #VisionRestTaggerはGoogle Cloud Vision API、REST API経由で画像解析しているクラス
    names = VisionRestTagger.new(photo).label_names
    #Tagモデルに保存、photoとの関連付け
    photo.set_ai_tags!(names)

    #処理成功ログ、実際に保存されたタグ名を表示
    Rails.logger.info("[AutoTagPhotoJob] tagged photo_id=#{photo.id} tags=#{photo.tags.pluck(:name)}")
    #ジョブが失敗してもアプリを落とさない、ログだけ出して終了
  rescue => e
    Rails.logger.error("[AutoTagPhotoJob] ERROR #{e.class}: #{e.message}")
  end
end
