class Routines::FinishesController < ApplicationController
  skip_before_action :playing_task_sesison_reset
  before_action :block_if_no_session

  def index
    current_user.complete_routines_count += 1
    current_user.save!
  end

  private

  def block_if_no_session
    redirect_to root_path, alert: 'ページに遷移できませんでした' if session[:playing_task_num].nil?
  end
end
