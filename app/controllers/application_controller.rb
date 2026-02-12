class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    stored = stored_location_for(resource)
    return stored if stored.present?

    # 連携済みなら写真一覧へ
    return photos_path if resource.line_user_id.present?

    # まずは友だち追加画面へ（LINEログイン後もメールログイン後も共通）
    # ただし「メール登録ユーザーで、まだLINEログイン登録してない」場合だけ connect を先に踏ませたい
    if email_registered_user?(resource) && (resource.provider.blank? || resource.uid.blank?)
      return connect_line_login_path
    end
    line_friend_path
  end

  def after_sign_up_path_for(resource)
    # 新規登録直後はまず友だち追加へ（ここから連携へ進ませる）
    return photos_path if resource.line_user_id.present?
    line_friend_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  private

  # メール登録ユーザーかどうかの判定
  # LINEログインユーザーは email が line_<uid>@example.local 形式なので除外できる
  def email_registered_user?(user)
    user.email.present? && !user.email.start_with?("line_") && !user.email.end_with?("@example.local")
  end
end
