class PhotosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_photo, only: [:show, :destroy]
  before_action :authorize_photo!, only: [:destroy]
  before_action :require_line_linked!

  def index
    @photos = current_user.photos.order(created_at: :desc)
    @photos_by_month = @photos.group_by { |photo| photo.created_at.in_time_zone.to_date.beginning_of_month }
  end

  def show
    @photo = Photo.find(params[:id])
    @comment = Comment.new
    @comments = @photo.comments.includes(:user).order(created_at: :desc)
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

  def require_line_linked!
    return if current_user.line_user_id.present?
    store_location_for(:user, request.fullpath)
    redirect_to link_line_path, alert: "写真を見るにはLINE連携が必要です"
  end
end