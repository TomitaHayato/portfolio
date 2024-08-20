class RoutinesController < ApplicationController
  before_action :set_routine, only: %i[ edit update destroy ]

  def index
    @routines = current_user.routines.order(created_at: :desc)
  end

  def new
    @routine = Routine.new
  end

  def create
    @routine = current_user.routines.new(routine_params)
    if @routine.save
      flash[:notice] = "新しくルーティンを作成しました"
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @routine.update(routine_params)
      flash[:notice] = "更新しました"
      redirect_to routines_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @routine.destroy!
    redirect_to routines_path, status: :see_other
  end

  private

  def routine_params
    params.require(:routine).permit(:title, :description, :start_time, :completed_count, :copied_count)
  end

  def set_routine
    @routine = current_user.routines.find(params[:id])
  end
end
