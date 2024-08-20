class TasksController < ApplicationController
  before_action :params_time_to_second

  def create
    @routine = current_user.routines.find(params[:routine_id])
    @task = routine.tasks.new(task_params)
    if @task.save
      flash[:notice] = "タスクを追加しました"
      redirect_to routine_path(routine)
    else
      @tasks = routine.tasks.order(created_at: :desc)
      render template: "routines/show", status: :unprocessable_entity
    end
  end

  private

  def task_params
    params.require(:task).permit(:title, :estimated_time_in_second)
  end

  def params_time_to_second
    hour = params[:task][:hour] * 3600
    minute = params[:task][:minute] * 60
    second = params[:task][:second]
    params[:task][:estimated_time_in_second] = hour + minute + second
  end
end
