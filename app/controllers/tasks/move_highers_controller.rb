class Tasks::MoveHighersController < ApplicationController
  def update
    task    = Task.find(params[:task_id])
    task.move_higher

    @routine = task.routine
    @tasks   = @routine.tasks.includes(:tags)
    @tags    = Tag.includes(:tasks)
  end
end
