class TasksController < ApplicationController
  include ApplicationHelper # task_form_id(task)メソッド

  before_action :params_time_to_second, only: %i[create update]
  before_action :set_task_and_routine , only: %i[update destroy]

  def create
    @routine = current_user.routines.includes(:tasks).find(params[:routine_id])
    @task    = @routine.tasks.new(task_params)
    @tags    = Tag.includes(:tasks)

    if @task.save
      @task.put_tags_on_task(task_params[:tag_ids])

      flash.now[:notice] = 'タスクを追加しました'
    else
      @form_id = task_form_id(@task)
      render 'tasks/error'
    end
  end

  def update
    @tags = Tag.includes(:tasks)

    if @task.update(task_params)
      selected_tag_ids = task_params[:tag_ids]
      @task.delete_tags_from_task(selected_tag_ids) # 元々指定されていたタグのうち、今回指定されていない=外されたタグを削除
      @task.put_tags_on_task(selected_tag_ids)      # 新しく指定されたタグを追加

      flash.now[:notice] = 'タスクを更新しました'
    else
      @form_id = task_form_id(@task)
      render 'tasks/error'
    end
  end

  def destroy
    @task.destroy!
    @tags = Tag.includes(:tasks)

    flash.now[:notice] = "#{@task.title}を削除しました。"
  end

  private

  def set_task_and_routine
    @task    = Task.includes(:tags).find(params[:id])
    @routine = @task.routine
  end

  def task_params
    params.require(:task).permit(:title, :estimated_time_in_second, tag_ids: [])
  end

  # フォームから送信された":hour, :minute, :second"のデータ => 秒数にしてparams[:task][:estimated_time_in_second]にまとめる
  def params_time_to_second
    params[:task][:estimated_time_in_second] = time_to_seconds(params[:task])
    delete_time_params
  end

  def time_to_seconds(params)
    hours   = params[:hour].to_i
    minutes = params[:minute].to_i
    seconds = params[:second].to_i

    (hours * 3600) + (minutes * 60) + seconds
  end

  # ストロングパラメータに引っかかるデータをparamsから削除
  def delete_time_params
    [:hour, :minute, :second].each { |key| params[:task].delete(key) }
  end
end
