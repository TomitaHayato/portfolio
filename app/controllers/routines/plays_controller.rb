class Routines::PlaysController < ApplicationController
  before_action :block_if_no_session, only: %i[ show update ]
  before_action :set_routine
  before_action :arrange_tasks_by_position, only: %i[ show update ]
  skip_before_action :playing_task_sesison_reset

  def create
    session[:playing_task_num] = 0
    redirect_to play_path(@routine)
  end

  def show
    @task = @tasks[ session[:playing_task_num] ]
  end

  def update
    session[:playing_task_num] += 1
    if session[:playing_task_num] >= @tasks.count
      @routine.completed_count += 1
      @routine.save!
      redirect_to routines_finishes_path
    else
      redirect_to play_path(@routine)
    end
  end

  private

  def set_routine
    @routine = current_user.routines.find(params[:routine_id])
  end

  def arrange_tasks_by_position
    @tasks = @routine.tasks.order(position: :asc)
  end

  # createアクションを介さないアクセスを拒否
  def block_if_no_session
    redirect_to root_path, alert: "ページに遷移できませんでした" if session[:playing_task_num].nil?
  end
end
