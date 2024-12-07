class Tasks::MoveLowersController < ApplicationController
  def update
    task = Task.find(params[:task_id])
    task.move_lower
    
    @routine = task.routine
    @tasks   = @routine.tasks.includes(:tags)
    @tags    = Tag.includes(:tasks)
  end
end
