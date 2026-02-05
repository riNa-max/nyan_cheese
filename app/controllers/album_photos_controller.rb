class AlbumPhotosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_owner
  before_action :set_photo
  before_action :authorize_album!

  def show
    @comment = Comment.new
    @comments = @photo.comments.includes(:user).order(created_at: :desc)
  end

  private

  def set_owner
    @owner = User.find(params[:album_id])
  end

  def authorize_album!
    allowed = (@owner.id == current_user.id) || AlbumFollow.exists?(owner: @owner, viewer: current_user)
    redirect_to albums_path, alert: 'アクセス権限がありません' unless allowed
  end

  def set_photo
    @photo = @owner.photos.find(params[:id])
  end

end
