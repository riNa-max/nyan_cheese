class SharesController < ApplicationController
  #before_actionより先に実行されるように設定（prepend_before_action）
  prepend_before_action :store_user_location, only: [:show]
  before_action :authenticate_user!

  def show
    #URLの:tokunを使ってDBから有効な共有リンクを検索。見つからなければ404(find_by!の動作)
    link = ShareLink.find_by!(token: params[:token], active: true)

    #意味のないフォロー関係の作成を防ぐため、自分のリンクの場合はリダイレクト
    if link.owner_id == current_user.id
      redirect_to photos_path ,notice: "これはあなたの共有リンクです。写真一覧にリダイレクトします。"
      return
    end

    #共有リンクの所有者と自分の間にフォロー関係がなければ作成(find_or_create_by!を使用)
    AlbumFollow.find_or_create_by!(owner: link.owner,viewer: current_user)

    #link.owner(=owner_idであり、ownerはUserオブジェクト)のアルバムページにリダイレクト
    redirect_to albums_path(link.owner), notice: "アルバムを追加しました。"
  end

  #privateに設定されたメソッドは関数形式でしか呼び出せないため、以下に記述
  private

  def store_user_location
    #未ログイン時だけ「遷移しようとしたURL」を保存
    store_location_for(:user, request.fullpath) unless user_signed_in?
  end
end
