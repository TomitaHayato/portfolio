class Tasks::MoveHighersController < ApplicationController
  def update
    task = Task.find(params[:task_id])
    task.move_heigher
    routine = task.routine
    redirect_to routine_path(routine)
  end
end
