class LineLinksController < ApplicationController
  before_action :authenticate_user!

  def show
    if current_user.line_link_token.blank?
      current_user.generate_line_link_token!
    end
  end

  def create
    current_user.generate_line_link_token!
    redirect_to line_link_path, notice: "連携コードを再発行しました"
  end
end
