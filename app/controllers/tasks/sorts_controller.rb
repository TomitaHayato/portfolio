class Tasks::SortsController < ApplicationController
  def update
    @task    = Task.find(params[:task_id])
    @routine = @task.routine
    @tasks   = @routine.tasks.includes(:tags)

    @task.insert_at(params[:new_index].to_i + 1)
  end
end
