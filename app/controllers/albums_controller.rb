class AlbumsController < ApplicationController
  before_action :authenticate_user!

  def index
    #AlbumFollowを通じて紐づいたUser一覧を取得
    @owners = current_user.following_owners
  end

  def show
    @owner = User.find(params[:id])
    
    #自分のアルバム、またはフォローしているアルバムのみ閲覧可能にする
    allowed = (@owner.id == current_user.id) ||
              AlbumFollow.exists?(owner: @owner, viewer: current_user)

    #allowがfalseの場合は、写真一覧にリダイレクト
    redirect_to photos_path, alert: "このアルバムは閲覧できません" and return unless allowed

    #写真を月ごとにグルーピングして取得
    #includes(image_attachment: :blob)でN+1問題を防止
    #↑Photoを取得する際に、image_attachmentおよびblobも同時に取得することを指定している
    @photos_by_month = @owner.photos.includes(image_attachment: :blob).order(created_at: :desc).group_by { |photo| photo.created_at.in_time_zone.to_date.beginning_of_month }
  end
end
