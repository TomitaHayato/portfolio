class TasksController < ApplicationController
  before_action :set_routine
  before_action :params_time_to_second
  
  def create
    @task = @routine.tasks.new(task_params)
    if @task.save
      flash[:notice] = "タスクを追加しました"
      redirect_to routine_path(@routine)
    else
      @tasks = routine.tasks.order(created_at: :desc)
      render template: "routines/show", status: :unprocessable_entity
    end
  end

  def update
    @task = Task.find(params[:id])
    if @task.update(task_params)
      flash[:notice] = "taskを更新しました"
      redirect_to routine_path(@routine)
    else
      @tasks = @routine.tasks.order(created_at: :desc)
      render template: "routines/show", status: :unprocessable_entity
  end

  private

  def set_routine
    @routine = current_user.routines.find(params[:routine_id])
  end

  def task_params
    params.require(:task).permit(:title, :estimated_time_in_second)
  end

  def params_time_to_second
    hour = params[:task][:hour].to_i * 3600
    minute = params[:task][:minute].to_i * 60
    second = params[:task][:second].to_i
    params[:task][:estimated_time_in_second] = hour + minute + second
  end
end
