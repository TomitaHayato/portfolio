class Tasks::MoveLowersController < ApplicationController
  def update
    task = Task.find(params[:task_id])
    task.move_lower
    routine = task.routine
    redirect_to routine_path(routine)
  end
end
