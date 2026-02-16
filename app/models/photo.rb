class Photo < ApplicationRecord
  has_one_attached :image
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :photo_tags, dependent: :destroy
  has_many :tags, through: :photo_tags

  #DB保存が確定してからジョブを投げる
  after_commit :enqueue_ai_tagging, on: :create

  # ==========
  # 共通：タグ保存（AIでも手動でも使う）
  # ==========
  def set_tags!(names)
    names = normalize_tag_names(names)

    # タグ付けは「一連の処理」。途中で失敗したら全部戻す
    transaction do
      photo_tags.delete_all
      return if names.empty?

      #map:要素を順番に取ってきて、指定した処理をしてくれるメソッド（配列.map { |変数| 実行する処理 }）
      #find_or_create_by!:既存のタグを取得、なければ作成
      tag_records = names.map { |name| Tag.find_or_create_by!(name: name) }
      #PhotoTagレコード生成
      tag_records.each { |tag| photo_tags.create!(tag: tag) }
    end
  end

  # ==========
  # AI：AIだけの前処理用
  # ==========
  def set_ai_tags!(names)
    set_tags!(names)
  end

  # ==========
  # 手動：フォーム入力（"cat dog, cute" みたいなの）を受ける用
  # ==========
  def set_manual_tags_from_string!(input)
    # 文字列でも配列でも受けられるよう normalize_tag_names に寄せる
    set_tags!(input)
  end

  private

  def enqueue_ai_tagging
    return unless image.attached?
    AutoTagPhotoJob.perform_later(photo_id: id)
  end

  # ==========
  # 正規化ロジック（ここに集約）
  # - 配列/文字列/nil なんでもOK
  # - カンマ/空白区切りOK
  # - 小文字化、重複排除、最大10個
  # ==========
  def normalize_tag_names(input)
    # まず文字列化してから、区切りで split して配列に統一
    raw =
      case input
      when nil
        []
      when String
        input.split(/[,\s]+/)
      else
        Array(input).flat_map { |v| v.to_s.split(/[,\s]+/) }
      end

    raw
      .map { |n| n.to_s.strip.downcase }
      .reject(&:blank?)
      .uniq
      .first(5)
  end
end
