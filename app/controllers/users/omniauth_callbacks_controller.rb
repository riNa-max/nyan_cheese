class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def line
    auth = request.env["omniauth.auth"]

    user = User.find_or_initialize_by(provider: auth.provider, uid: auth.uid)

    user.email = "line_#{auth.uid}@example.local" if user.email.blank?
    user.password = Devise.friendly_token[0, 20] if user.encrypted_password.blank?
    user.save!

    sign_in(user)
    redirect_to after_sign_in_path_for(user), notice: "LINEでログインしました"
  end

  def failure
    redirect_to new_user_session_path
  end
end
