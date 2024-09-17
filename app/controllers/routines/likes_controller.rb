class Routines::LikesController < ApplicationController
  before_action :set_routine

  def create
    current_user.liked_routines << @routine
    @liked_routine_ids = current_user.liked_routine_ids
    render turbo_stream: turbo_stream.update("routine-like-btn-#{@routine.id}", partial: 'routines/posts/routine_like_btn', locals: { routine: @routine, liked_routine_ids: @liked_routine_ids  })
  end

  def destroy
    current_user.liked_routines.destroy(@routine)
    @liked_routine_ids = current_user.liked_routine_ids
    render turbo_stream: turbo_stream.update("routine-like-btn-#{@routine.id}", partial: 'routines/posts/routine_like_btn', locals: { routine: @routine, liked_routine_ids: @liked_routine_ids  })
  end

  private

  def set_routine
    @routine = Routine.find(params[:routine_id])
  end
end
