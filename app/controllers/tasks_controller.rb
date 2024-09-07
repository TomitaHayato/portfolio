class TasksController < ApplicationController
  include ApplicationHelper

  before_action :params_time_to_second, only: %i[create update]
  before_action :set_task_and_routine, only: %i[update destroy]

  def create
    @routine = current_user.routines.find(params[:routine_id])
    @task = @routine.tasks.new(task_params)
    if @task.save
      flash.now[:notice] = 'タスクを追加しました'
    else
      render turbo_stream: turbo_stream.replace("#{task_form_id(@task)}", partial: "routines/task_form", locals: { task: @task, routine: @routine })
    end
  end

  def update
    if @task.update(task_params)
      flash.now[:notice] = 'タスクを更新しました'
    else
      render turbo_stream: turbo_stream.replace("#{task_form_id(@task)}", partial: "routines/task_form", locals: { task: @task, routine: @routine })
    end
  end

  def destroy
    @task.destroy!
    flash[:notice] = "タスクを削除しました。(タスク名：#{@task.title})"
    redirect_to routine_path(@routine), status: :see_other
  end

  private

  def set_task_and_routine
    @task = Task.find(params[:id])
    @routine = @task.routine
  end

  def task_params
    params.require(:task).permit(:title, :estimated_time_in_second)
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
