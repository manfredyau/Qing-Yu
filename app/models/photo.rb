class Photo < ApplicationRecord
  belongs_to :user
  belongs_to :reviewer, class_name: "AdminUser", foreign_key: :reviewed_by, optional: true

  has_one_attached :file

  enum :status, { pending: 0, approved: 1, rejected: 2 }, default: :pending, validate: true

  ALLOWED_TYPES = %w[image/jpeg image/png image/webp].freeze

  validate :validate_file

  scope :approved, -> { where(status: :approved) }
  scope :ordered, -> { order(:position, :id) }
  scope :primary, -> { where(primary: true) }

  after_commit :ensure_single_primary, on: %i[ create update ], if: :primary?
  after_destroy :reassign_primary

  private
    def validate_file
      return errors.add(:file, "请选择图片文件") unless file.attached?

      errors.add(:file, "仅支持 JPG / PNG / WebP 格式") unless ALLOWED_TYPES.include?(file.blob.content_type)
      errors.add(:file, "图片大小不能超过 10MB") if file.blob.byte_size > 10.megabytes
    end

    # 同一用户仅允许一张主图；设置时清除其他主图
    def ensure_single_primary
      return unless primary?
      user.photos.where(primary: true).where.not(id: id).update_all(primary: false)
    end

    def reassign_primary
      return unless primary?
      user.photos.approved.order(:position, :id).first&.update!(primary: true)
    end
end
