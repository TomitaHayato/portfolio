class Routines::ActivesController < ApplicationController

  def update
    routine = Routine.find(params[:routine_id])
    routine_active_now = Routine.find_by(is_active: true)
    unless routine == routine_active_now
        routine_active_now.update!(is_active: false) if routine_active_now
        routine.update!(is_active: true)
    end
    redirect_to routines_path
  end
end
