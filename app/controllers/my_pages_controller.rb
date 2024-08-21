class MyPagesController < ApplicationController
  def index
    @routine = current_user.routines.includes(:tasks).find_by(is_active: true)
  end
end
