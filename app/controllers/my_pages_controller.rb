class MyPagesController < ApplicationController
  def index
    @routine = current_user.routines.active
  end
end
