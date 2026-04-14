class TagsController < ApplicationController
  protect_from_forgery

  def create
    @photo = Photo.find(params[:photo_id])
    #これだけで中間テーブルの更新をしてくれる
    @photo.update(photo_params)
  end

  private

  def photo_params
    # tag_idsのようにしておくと一対多または多対多で結んだ相手を親レコードに結びつけて自動更新してくれる
    # 今回は中間テーブルの更新だけで良いので、特にコードの追記がないので便利
    params.require(:photo).permit(tag_ids: [])
  end
end