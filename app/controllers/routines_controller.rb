class RoutinesController < ApplicationController
  before_action :set_routine, only: %i[show edit update destroy]
  before_action :set_order_query, only: %i[index]
  before_action :set_filter_target, only: %i[index]
  
  def index
    @tags = Tag.includes(:tasks).all
    @routines = current_user.routines.search(params[:user_words]).custom_filter(@filter_target, current_user.id).includes(tasks: :tags).sort_routine(@column, @direction).page(params[:page])
    @user_words = params[:user_words]
    @auto_complete_list = (current_user.routines.pluck(:title) + current_user.routines.pluck(:description).reject(&:blank?)).uniq
  end

  def show
    @task = Task.new
    @tasks = @routine.tasks.includes(:tags).order(position: :asc)
  end

  def new
    @routine = Routine.new
  end

  def edit; end

  def create
    @routine = current_user.routines.new(routine_params)
    @routine.is_active = true if current_user.routines.size == 1

    if @routine.save
      redirect_to routine_path(@routine), notice: '作成したルーティンにタスクを追加しましょう！'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @routine.update(routine_params)
      redirect_to routine_path(@routine), notice: 'ルーティンを更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @routine.destroy!
    from_path = params[:from_path] # 遷移元のパス、どのページから削除したのかを判別する
    flash[:alert] = "#{@routine.title}を削除しました"

    # 「詳細ページから削除した場合」または「ルーティンを削除したことでユーザーに属するルーティンが0個になった場合」は一覧画面にリダイレクト
    redirect_to routines_path, status: :see_other if from_path == routine_path(@routine) || current_user.routines.empty?
  end

  private

  def set_order_query
    @column = params[:column]
    @direction = params[:direction]
    @order_list = [['作成日', nil], ['達成数', 'completed_count']]
  end

  def set_filter_target
    @filter_target = params[:filter_target]
    @filter_options = [['すべて', nil], ['投稿済み', 'posted'], ['未投稿', 'unposted']]
  end

  def routine_params
    params.require(:routine).permit(:title, :description, :start_time)
  end

  def set_routine
    @routine = current_user.routines.find(params[:id])
  end
end
