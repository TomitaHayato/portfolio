class Routines::CopiesController < ApplicationController
  before_action :guest_block, only: %i[create]

  # TODO: トランザクション処理をしなければならない（Routineの保存 => Taskの保存 => TaskTagの保存）
  def create
    # コピーされた数を+1する
    routine_origin = Routine.includes(tasks: :tags).find(params[:routine_id])
    routine_origin.copy_count
    # ルーティン内容をコピーする
    routine_dup = routine_origin.copy(current_user)
    # タスクをコピーする
    routine_origin.copy_tasks(routine_dup)

    flash.now[:notice] = "コピーしました。（#{routine_origin.title}）"
  end
end
