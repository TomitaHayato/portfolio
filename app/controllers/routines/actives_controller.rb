class Routines::ActivesController < ApplicationController

  def create
    # 現在実践中のルーティンを実践前状態に変更
    routine_active_now = Routine.find_by(is_active: true)
    routine_active_now.update!(is_active: false) if routine_active_now

    routine = Routine.find(params[:routine_id])
    routine.update!(is_active: true)
    redirect_to routines_path
  end
end
