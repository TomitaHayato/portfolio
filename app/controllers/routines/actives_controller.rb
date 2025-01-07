class Routines::ActivesController < ApplicationController
  def update
    @routine = current_user.routines.find(params[:routine_id])
    return if @routine.is_active?

    # 元々activeだったルーティンを非アクティブ化
    @routine_active_now = current_user.routines.find_by(is_active: true)
    @routine_active_now&.update!(is_active: false)

    @routine.update!(is_active: true)
  end
end
