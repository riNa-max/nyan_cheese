class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    #resouceはモデルのインスタンスに相当（=current_user）
    # まずはdeviseが保存してくれたURLを優先的に取得
    # それがなければsuperでデフォルトの挙動を呼び出し
    stored_location_for(resource) || super

    return photos_path if resource.line_user_id.present?
    line_friend_path
  end

  def after_sign_up_path_for(resource)
    photos_path
  end

  protected


  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

end
