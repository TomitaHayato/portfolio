class RoutinesController < ApplicationController
  def new
    @routine = Routine.new
  end

  def create
    @routine = current_user.routines.new(routine_params)
    if @routine.save!
      flash[:notice] = "新しくルーティンを作成しました"
      redirect_to root_path
    else
      render :new, :unprocessable_entity
    end
  end

  private

  def routine_params
    params.require(:routine).permit(:title, :description, :start_time, :completed_count, :copied_count)
  end
end
