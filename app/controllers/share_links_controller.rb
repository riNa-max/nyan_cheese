class ShareLinksController < ApplicationController
  def index
    #自分が発行したリンクの一覧を表示
    @share_links = current_user.share_links.order(created_at: :desc)
  end

  def create
    #新しい共有リンクを発行。詳細は、モデル側で設定
    current_user.share_links.create!
    redirect_to share_links_path, notice: "新しい共有リンクを作成しました。"
  end

  def destroy
    link=current_user.share_links.find(params[:id])
    #共有リンクを削除ではなく、無効化にする。DB側で制約をかけているため。
    link.update!(active: false)
    redirect_to share_links_path, notice: "共有リンクを無効化しました。"
  end
end
