class Routines::CopiesController < ApplicationController
  def create
    # コピーされた数を+1する
    routine_origin = Routine.includes(:tasks).find(params[:routine_id])
    copy_counting(routine_origin)
    # ルーティン内容をコピーする
    routine_dup = copy_routine(routine_origin)
    # タスクをコピーする
    copy_tasks(routine_origin, routine_dup)

    flash[:notice] = "コピーしました。（#{routine_origin.title}）"
    redirect_to routines_posts_path
  end

  private

  def copy_counting(routine_origin)
    routine_origin.copied_count += 1
    routine_origin.save!
  end

  def copy_routine(routine_origin)
    routine_dup = routine_origin.dup.reset_status
    routine_dup.update!(user_id: current_user.id)
    return routine_dup
  end

  def copy_tasks(routine_origin, routine_dup)
    routine_origin.tasks.each do |task|
      task_dup = task.dup.update!(routine_id: routine_dup.id)
    end
  end
end
