class PhotosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_photo, only: [:show, :destroy]
  before_action :authorize_photo!, only: [:destroy]

  def index
    @photos = current_user.photos.order(created_at: :desc)
  end

  def show
  end

  def destroy
    @photo.destroy
    redirect_to photos_path, notice: '削除しました'
  end

  private

  def set_photo
    @photo = current_user.photos.find(params[:id])
  end

  def authorize_photo!
    return if @photo.user_id == current_user.id
    redirect_to photos_path, alert: 'アクセス権限がありません' unless @photo.user == current_user
  end

end
