class PhotosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_photo, only: [:show, :destroy]
  before_action :authorize_photo!, only: [:destroy]
  before_action :require_line_linked!

  def index
    #パラメータ取得
    #nil対策で to_s、空白除去で strip
    @tag = params[:tag].to_s.strip
    @month = params[:month].to_s.strip

    scope = current_user.photos.includes(:tags).order(created_at: :desc)

    if @month.present?
      from = Time.zone.parse("#{@month}-01").beginning_of_month
      to = from.end_of_month
      scope = scope.where(created_at: from..to)
    end

    if @tag.present?
      scope = scope.joins(:tags)
                  .where("tags.name_ja = ? OR tags.name = ?", @tag, @tag.downcase)
                  .distinct
    end

    @photos = scope
    @photos_by_month = @photos.group_by { |photo| photo.created_at.in_time_zone.to_date.beginning_of_month }

    @all_tags = Tag.joins(:photos)
                  .where(photos: { user_id: current_user.id })
                  .distinct
                  .order(:name_ja, :name)
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