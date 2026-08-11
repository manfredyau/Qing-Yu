class Current < ActiveSupport::CurrentAttributes
  attribute :session

  delegate :sessionable, to: :session, allow_nil: true

  def user
    sessionable if sessionable.is_a?(User)
  end

  def admin_user
    sessionable if sessionable.is_a?(AdminUser)
  end
end
