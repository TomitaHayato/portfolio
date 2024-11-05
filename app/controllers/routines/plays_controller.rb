class Routines::PlaysController < ApplicationController
  before_action      :block_if_no_session       , only: %i[show update]
  before_action      :set_routine
  before_action      :set_tasks                 , only: %i[show update]
  skip_before_action :playing_task_sesison_reset

  def show
    @task = @tasks[session[:playing_task_num]]
    # 最後のタスクの場合、turbo-frameリクエストを無効化
    @turbo_setting = { turbo_method: :patch }
    @turbo_setting[:turbo_frame] = '_top' if session[:playing_task_num] == (@tasks.count - 1)
  end

  def create
    session[:playing_task_num] = 0 # 次に実行するtaskの順番を管理
    session[:experience_log] = Hash.new # どのタグの経験値をどのくらい獲得したのかを管理
    redirect_to play_path(@routine)
  end

  def update
    session[:playing_task_num] += 1
    session[:experience_log] = set_experience_log(session[:experience_log], params[:tag_ids]) if params[:tag_ids]

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

  def set_tasks
    @tasks = @routine.tasks
  end

  # createアクションを介さないアクセスを拒否
  def block_if_no_session
    redirect_to my_pages_path, alert: 'ページに遷移できませんでした' if session[:playing_task_num].nil?
  end

  # タグidと達成した回数を経験値管理ハッシュに格納する
  def set_experience_log(experience_log, tag_ids)
    tag_ids.each do |tag_id|
      experience_log[tag_id] ||= 0
      experience_log[tag_id] += 1
    end
    experience_log
  end
end
