class TasksController < ApplicationController
  include ApplicationHelper

  before_action :params_time_to_second, only: %i[create update]
  before_action :set_task_and_routine, only: %i[update destroy]

  def create
    @routine = current_user.routines.find(params[:routine_id])
    @task = @routine.tasks.new(task_params)
    if @task.save
      set_tags_on_task(@task, task_params[:tag_ids])
      flash.now[:notice] = 'タスクを追加しました'
    else
      render turbo_stream: turbo_stream.replace(task_form_id(@task).to_s, partial: 'routines/task_form', locals: { task: @task, routine: @routine, tags: Tag.all })
    end
  end

  def update
    if @task.update(task_params)
      p task_params
      delete_tags_from_task(@task, task_params[:tag_ids])
      set_tags_on_task(@task, task_params[:tag_ids])
      flash.now[:notice] = 'タスクを更新しました'
    else
      render turbo_stream: turbo_stream.replace(task_form_id(@task).to_s, partial: 'routines/task_form', locals: { task: @task, routine: @routine, tags: Tag.all })
    end
  end

  def destroy
    @task.destroy!
    flash[:notice] = "タスクを削除しました。(タスク名：#{@task.title})"
    redirect_to routine_path(@routine), status: :see_other
  end

  private

  def set_task_and_routine
    @task = Task.includes(:tags).find(params[:id])
    @routine = @task.routine
  end

  def task_params
    params.require(:task).permit(:title, :estimated_time_in_second, tag_ids: [])
  end

  # 新しく指定されたタグをタスクに追加する
  def set_tags_on_task(task, tag_ids)
    return if tag_ids.nil?
    tag_ids = tag_ids.map{ |tag_id| tag_id.to_i }
    tag_ids.each{ |tag_id| task.tags << Tag.find(tag_id) unless task.tag_ids.include?(tag_id) }
  end

  # 元々セットされていたが今回選択されていなかったタグを削除
  def delete_tags_from_task(task, tag_ids)
    tag_ids = [] if tag_ids.nil?
    tag_ids = tag_ids.map{ |tag_id| tag_id.to_i }
    task.tags.each{ |tag| task.tags.destroy(tag) unless tag_ids.include?(tag) }
  end

  def params_time_to_second
    params[:task][:estimated_time_in_second] = hour_to_second(params[:task][:hour]) + minute_to_second(params[:task][:minute]) + params[:task][:second].to_i
    delete_time_params
  end

  def hour_to_second(hour)
    hour.to_i * 3600
  end

  def minute_to_second(minute)
    minute.to_i * 60
  end

  def delete_time_params
    [:hour, :minute, :second].each { |key| params[:task].delete(key) }
  end
end
