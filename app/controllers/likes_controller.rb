class LikesController < ApplicationController
  before_action :set_routine
  def create
    current_user.liked_routines << @routine
  end

  def destroy
    current_user.liked_routines.destroy!(@routine)
  end

  private

  def set_routine
    @routine = Routine.find(params[:routine_id])
  end
end
