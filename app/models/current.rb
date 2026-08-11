class Current < ActiveSupport::CurrentAttributes
  attribute :session, :admin_session

  def user
    sessionable = session&.sessionable
    sessionable if sessionable.is_a?(User)
  end

  def admin_user
    sessionable = admin_session&.sessionable
    sessionable if sessionable.is_a?(AdminUser)
  end
end
