class Routines::CopiesController < ApplicationController
  before_action :guest_block, only: %i[create]

  def create
    routine_origin = Routine.includes(tasks: :tags).find(params[:routine_id])

    begin
      # Routine,Task,TaskTagレコードの内容をコピー
      routine_origin.copy(current_user)
      flash.now[:notice] = "コピーしました。（#{routine_origin.title}）"
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("コピー失敗: #{e.message}")
      flash.now[:alert] = 'コピーできませんでした'
    end
  end
end
