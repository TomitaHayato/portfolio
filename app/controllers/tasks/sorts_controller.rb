class Tasks::SortsController < ApplicationController
  def update
    @task    = Task.find(params[:task_id])
    @task.insert_at(params[:new_index].to_i + 1)

    @routine = @task.routine
    @tasks   = @routine.tasks.includes(:tags)
    @tags    = Tag.includes(:tasks)
  end
end
