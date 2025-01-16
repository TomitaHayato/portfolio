class Routines::PlaysController < ApplicationController
  before_action      :block_if_no_session       , only: %i[show update]
  before_action      :set_routine_and_tasks     , only: %i[show update]
  skip_before_action :playing_task_sesison_reset

  def show
    set_task_and_turbo_options
  end

  def create
    session[:task_index] = 0  # 次に実行するtaskの順番を管理
    session[:exp_log]    = {} # どのタグの経験値をどのくらい獲得したのかを管理: {tag_id: exp}
    session[:start_time] = Time.current.to_i

    redirect_to play_path(params[:routine_id])
  end

  def update
    session[:task_index] += 1
    session[:exp_log]     = set_exp_log(session[:exp_log], params[:tag_ids]) if params[:tag_ids]

    if session[:task_index] >= @tasks.size
      @routine.complete_count
      redirect_to routine_finishes_path
    else
      set_task_and_turbo_options
      render :show
    end
  end

  private

  def set_routine_and_tasks
    @routine = current_user.routines.find(params[:routine_id])
    @tasks   = @routine.tasks
  end

  def set_task_and_turbo_options
    @task          = @tasks[session[:task_index]] # 取り組むTask
    @turbo_options = { turbo_method: :patch }

    # 最後のタスクの場合は完了ページに遷移するため、turbo-frameリクエストを無効化
    @turbo_options[:turbo_frame] = '_top' if session[:task_index] == (@tasks.size - 1)
  end

  # createアクションを介さないアクセスを拒否
  def block_if_no_session
    redirect_to my_pages_path, alert: 'ページに遷移できませんでした' if session[:task_index].nil? || session[:exp_log].nil? || session[:start_time].nil?
  end

  # タグidと達成した回数を経験値管理ハッシュに格納する
  def set_exp_log(exp_log, tag_ids)
    tag_ids.each do |tag_id|
      exp_log[tag_id] ||= 0
      exp_log[tag_id]  += 1
    end

    exp_log # {"tag_id": 獲得exp}
  end
end
