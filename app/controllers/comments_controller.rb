class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_photo
  before_action :set_comment, only: [:destroy]
  before_action :authorize_destroy!, only: [:destroy]

  def create
    #写真に紐づいたコメントを作成
    #buildメソッドを使用して、current_userをコメントのuser属性に設定
    #コメントの投稿者を現在ログイン中のユーザーに固定 
    @comment = @photo.comments.build(comment_params.merge(user: current_user))

    if @comment.save
      redirect_to after_comment_path, notice: "コメントが投稿されました。"
    else
      #includes:関連データをまとめて先読みするためのメソッド
      @comments = @photo.comments.includes(:user).order(created_at: :desc)
      #unprocessable_entity:4エラーメッセージを出力
      render "albun_photos/show", status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    redirect_to after_comment_path, notice: "コメントが削除されました。"
  end

  private

  def authorize_destroy!
    return if @comment.user_id == current_user.id
    redirect_to after_comment_path, alert: "権限がありません。" unless @comment.user == current_user
  end

  def after_comment_path
    if params[:album_id].present?
      owner = User.find(params[:album_id])
      album_photo_path(owner, @photo)
    else
      photo_path(@photo)
    end
  end

  def comment_params
    #strong parametersを使用して、コメントのbody属性のみを許可
    params.require(:comment).permit(:body)
  end

  def set_photo
    @photo = Photo.find(params[:photo_id])
  end

  def set_comment
    @comment = @photo.comments.find(params[:id])
  end

end