class TasksController < ApplicationController
  before_action :params_time_to_second, only: %i[ create update ]
  before_action :set_task_and_routine, only: %i[ update destroy ]
  
  def create
    @routine = current_user.routines.find(params[:routine_id])
    @task = @routine.tasks.new(task_params)
    if @task.save
      flash[:notice] = "タスクを追加しました"
      redirect_to routine_path(@routine)
    else
      @tasks = @routine.tasks.order(created_at: :desc)
      flash.now[:alert] = "タスクを追加できませんでした"
      render template: "routines/show", status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      flash[:notice] = "タスクを更新しました"
      redirect_to routine_path(@routine)
    else
      @tasks = @routine.tasks.order(created_at: :desc)
      flash.now[:alert] = "タスクを更新できませんでした。"
      render template: "routines/show", status: :unprocessable_entity
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
    hour = params[:task][:hour].to_i * 3600
    minute = params[:task][:minute].to_i * 60
    second = params[:task][:second].to_i
    params[:task][:estimated_time_in_second] = hour + minute + second

    params[:task].delete(:hour)
    params[:task].delete(:minute)
    params[:task].delete(:second)
  end
end
