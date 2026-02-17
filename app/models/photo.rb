class Photo < ApplicationRecord
  has_one_attached :image
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :photo_tags, dependent: :destroy
  has_many :tags, through: :photo_tags

  after_commit :enqueue_ai_tagging, on: :create

  # ==========
  # 共通：タグ保存（AIでも手動でも使う）
  # ==========
  def set_tags!(names, source: :manual)
    names = normalize_tag_names(names)

    transaction do
      photo_tags.delete_all
      return if names.empty?

      #既存タグは再利用、なければ作る
      tag_records = names.map { |name| Tag.find_or_create_by!(name: name) }

      # AI由来のときだけ、日本語訳(name_ja)を埋める
      fill_missing_tag_ja!(tag_records) if source.to_sym == :ai

      #PhotoTagを作る
      tag_records.each { |tag| photo_tags.create!(tag: tag) }
    end
  end

  # ==========
  # AI：AIだけの前処理用
  # ==========
  def set_ai_tags!(names)
    #AIが付けたタグは source: :ai で保存
    set_tags!(names, source: :ai)
  end

  # ==========
  # 手動：フォーム入力を受ける用
  # ==========
  def set_manual_tags_from_string!(input)
    #フォーム入力は source: :manual
    set_tags!(input, source: :manual)
  end

  private

  def enqueue_ai_tagging
    return unless image.attached?
    AutoTagPhotoJob.perform_later(photo_id: id)
  end

  # 日本語訳を tags.name_ja に埋める
  def fill_missing_tag_ja!(tags)
    targets = tags.select { |t| t.name_ja.blank? }
    return if targets.empty?

    # 英語っぽいものだけ翻訳（日本語タグを誤翻訳しないため）
    targets = targets.select { |t| t.name.to_s.match?(/\A[\x00-\x7F]+\z/) }
    return if targets.empty?

    #Translation APIでまとめて翻訳
    translator = GoogleTranslateRest.new(project_id: ENV.fetch("GCP_PROJECT_ID"))
    map = translator.translate_texts(targets.map(&:name), target: "ja", source: "en")

    #tags.name_ja に保存してキャッシュ化
    #次回以降は翻訳APIを叩かずに日本語表示できる
    targets.each do |tag|
      ja = map[tag.name].to_s.strip
      next if ja.empty?
      tag.update!(name_ja: ja)
    end
  end

  def normalize_tag_names(input)
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
      .first(10)
  end
end
