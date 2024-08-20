class MyPagesController < ApplicationController
  def index
    @routine = current_user.routines.find_by(is_active: true)
  end
end
