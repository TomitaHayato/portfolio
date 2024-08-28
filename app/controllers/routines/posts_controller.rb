class Routines::PostsController < ApplicationController
  def index
    @routines = Routine.includes(:tasks, :user).posted.order(posted_at: :desc).page(params[:page]).per(1)
  end

  def update
    routine = current_user.routines.find(params[:routine_id])
    if routine.is_posted?
      routine.update!(is_posted: false)
      redirect_to routines_path, notice: "ルーティンを非公開にしました"
    else
      routine.update!(is_posted: true, posted_at: Time.current)
      redirect_to routines_path, notice: "ルーティンを投稿しました"
    end
  end
end
