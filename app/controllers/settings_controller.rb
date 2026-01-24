class SettingsController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(settings_params)
      redirect_to settings_path, notice: "設定を保存しました"
    else
      flash.now[:alert] = "設定の保存に失敗しました"
      render :show
    end
  end

  private

  def settings_params
    params.require(:user).permit(:remind_enabled, :remind_after_days)
  end

end
