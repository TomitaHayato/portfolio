class RoutinesController < ApplicationController
  before_action :set_routine      , only: %i[show update destroy]
  before_action :set_order_query  , only: %i[index]
  before_action :set_filter_target, only: %i[index]

  def index
    @tags               = Tag.includes(:tasks).all
    @routines           = current_user.routines.search(params[:user_words]).custom_filter(@filter_target, current_user.id).includes(tasks: :tags).sort_routine(@column, @direction).page(params[:page])
    @user_words         = params[:user_words]
    @auto_complete_list = current_user.routines.make_routine_autocomplete_list
  end

  def show
    @task           = Task.new
    @tasks          = @routine.tasks.includes(:tags).order(position: :asc)
    @tags           = Tag.includes(:tasks)
    @all_task_names = current_user.routines.includes(:tasks).make_task_autocomplete_list
  end

  def new
    @routine = Routine.new
  end

  def create
    @routine           = current_user.routines.new(routine_params)
    @routine.is_active = true if current_user.routines.size == 1

    if @routine.save
      redirect_to routine_path(@routine), notice: '作成したルーティンにタスクを追加しましょう！'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @routine.update(routine_params)
      respond_to do |format|
        format.html { redirect_to routine_path(@routine) }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render :show, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            'routine-edit-form',
            partial: 'routines/edit_form',
            locals:  { routine: @routine }
          )
        end
      end
    end
  end

  def destroy
    @routine.destroy!
    from_path     = params[:from_path] # 遷移元のパス、どのページから削除したのかを判別する
    flash[:alert] = "#{@routine.title}を削除しました"

    # 「詳細ページから削除した場合」または「ルーティンを削除したことでユーザーに属するルーティンが0個になった場合」は一覧画面にリダイレクト
    redirect_to routines_path, status: :see_other if from_path == routine_path(@routine) || current_user.routines.empty?
  end

  private

  # rubocop:disable Style/WordArray
  def set_order_query
    @column     = params[:column]
    @direction  = params[:direction]
    @order_list = [['作成日', nil], ['達成数', 'completed_count']]
  end

  def set_filter_target
    @filter_target  = params[:filter_target]
    @filter_options = [['すべて', nil], ['投稿済み', 'posted'], ['未投稿', 'unposted']]
  end
  # rubocop:enable Style/WordArray

  def routine_params
    params.require(:routine).permit(:title, :description, :start_time)
  end

  def set_routine
    @routine = current_user.routines.find(params[:id])
  end
end
