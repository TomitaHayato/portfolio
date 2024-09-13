class Routines::PostsController < ApplicationController
  def index
    @routines = Routine.includes(:tasks, :user).posted.order(posted_at: :desc).page(params[:page])
  end

  def update
    @routine = current_user.routines.find(params[:routine_id])
    if @routine.is_posted?
      @routine.update!(is_posted: false)
      flash.now[:notice] = 'ルーティンを非公開にしました'
    else
      @routine.update!(is_posted: true, posted_at: Time.current)
      flash.now[:notice] = 'ルーティンを投稿しました'
    end
  end
end
