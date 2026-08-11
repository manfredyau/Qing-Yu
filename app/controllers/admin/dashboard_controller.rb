module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        users: User.count,
        verified_users: User.verified.count,
        pending_identity: IdentityVerification.pending.count,
        pending_education: EducationVerification.pending.count,
        pending_photos: Photo.pending.count,
        matches: Match.count
      }
    end
  end
end
