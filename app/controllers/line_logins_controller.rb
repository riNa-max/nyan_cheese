class LineLoginsController < ApplicationController
  before_action :authenticate_user!

  def new
    # すでに登録済みなら次へ（LINE連携へ or photosへ）
    if current_user.provider.present? && current_user.uid.present?
      redirect_to next_after_line_login_path
    end
  end

  def create
    # OmniAuthに飛ばす。connect=1 を付けて「紐付けモード」として扱う
    redirect_to user_line_omniauth_authorize_path(connect: 1)
  end

  private

  def next_after_line_login_path
    if current_user.line_user_id.present?
      stored_location_for(:user) || photos_path
    else
      link_line_path
    end
  end
end
