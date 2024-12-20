class Routines::CopiesController < ApplicationController
  before_action :guest_block, only: %i[create]

  def create
    # コピーされた数を+1する
    routine_origin = Routine.includes(tasks: :tags).find(params[:routine_id])
    routine_origin.copy_count
    # ルーティン内容をコピーする
    routine_dup = routine_origin.copy(current_user)
    # タスクをコピーする
    copy_tasks(routine_origin, routine_dup)

    flash.now[:notice] = "コピーしました。（#{routine_origin.title}）"
  end

  private

  def copy_tasks(routine_origin, routine_dup)
    routine_origin.tasks.each do |task_origin|
      task_dup = task_origin.dup
      task_dup.update!(routine_id: routine_dup.id)
      task_dup.insert_at(task_origin.position)
      copy_tags(task_origin, task_dup)
    end
  end

  # コピー元のTaskについたtagをコピー先にも紐付ける
  # task_dupはDBに保存されている必要がある
  def copy_tags(task_origin, task_dup)
    TaskTag.insert_all(copy_task_tag_info(task_origin, task_dup)) unless task_origin.tags.empty?
    task_dup
  end

  # TaskTagsテーブルに保存する情報をもつ配列を作成する
  def copy_task_tag_info(task_origin, task_dup)
    copied_task_tag_info = task_origin.tag_ids.map do |tag_id|
      {
        tag_id: tag_id,
        task_id: task_dup.id
      }
    end
  end
end
