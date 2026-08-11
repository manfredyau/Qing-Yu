class MatchesController < ApplicationController
  def index
    @matches = current_user.matches.active.recent
  end
end
