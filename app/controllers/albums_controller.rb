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

    @tag = params[:tag].to_s.strip
    @month = params[:month].to_s.strip

    scope = @owner.photos.includes(:tags).order(created_at: :desc)

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

    @photos = scope.includes(image_attachment: :blob) 

    #写真を月ごとにグルーピングして取得
    #includes(image_attachment: :blob)でN+1問題を防止
    #↑Photoを取得する際に、image_attachmentおよびblobも同時に取得することを指定している
    @photos_by_month = @photos.group_by do |photo|
      photo.created_at.in_time_zone.to_date.beginning_of_month
    end 
    
    @all_tags = Tag.joins(:photo_tags)
               .where(photo_tags: { photo_id: @owner.photos.select(:id) })
               .distinct
               .order(:name)   
  end
end
