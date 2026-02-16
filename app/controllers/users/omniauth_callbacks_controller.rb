class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def line
    #OmniAuthがLINEから返してくれる情報（provider, uid, etc.）がここに入ってる
    auth = request.env["omniauth.auth"]

    # connect判定は request.params じゃなく omniauth.params
    #OAuthで外部に飛んで戻ってくるので、通常のparamsがそのまま残らないことがある
    omniauth_params = request.env["omniauth.params"] || {}
    #LINEログイン開始URLに ?connect=1 を付けた場合、それが omniauth.params に入る
    connect_mode = omniauth_params["connect"].to_s == "1"

    # ====== 既存ユーザーに「LINEログイン登録」するモード ======
    if connect_mode
      # connectは「ログイン中の人だけ」が前提
      unless user_signed_in?
        #connectは「今ログインしてるアカウントに、LINEログインを追加する」動きなので、未ログインなら弾く
        redirect_to new_user_session_path, alert: "先にログインしてください"
        return
      end

      # すでに他ユーザーが同じ provider/uid を持ってたら事故るので弾く（任意だけど強く推奨）
      already = User.find_by(provider: auth.provider, uid: auth.uid)
      if already && already.id != current_user.id
        redirect_to connect_line_login_path, alert: "このLINEアカウントは既に別のユーザーに登録されています"
        return
      end

      current_user.update!(provider: auth.provider, uid: auth.uid)

      # 次はLINE連携へ（未なら）/ photosへ（済なら）
      if current_user.line_user_id.blank?
        redirect_to line_friend_path, notice: "LINEログイン登録が完了しました。続けてLINE連携を完了してください。"
      else
        redirect_to photos_path, notice: "LINEログイン登録が完了しました。"
      end
      return
    end

    # ====== 通常の「LINEでログイン」 ======
    user = User.find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    user.email = "line_#{auth.uid}@example.local" if user.email.blank?
    user.password = Devise.friendly_token[0, 20] if user.encrypted_password.blank?
    user.save!

    sign_in(user)

    if user.line_user_id.blank?
      redirect_to line_friend_path, notice: "LINEログイン登録が完了しました。次に友だち追加→LINE連携を完了してください。"
    else
      redirect_to photos_path, notice: "LINEでログインしました。"
    end
  end

  def failure
    redirect_to new_user_session_path
  end
end
