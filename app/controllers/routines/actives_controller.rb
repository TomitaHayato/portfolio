class Routines::ActivesController < ApplicationController

  def update
    routine = current_user.routines.find(params[:routine_id])
    routine_active_now = current_user.routines.find_by(is_active: true)
    unless routine == routine_active_now
        routine_active_now.update!(is_active: false) if routine_active_now
        routine.update!(is_active: true)
    end
    redirect_to routines_path
  end
end
