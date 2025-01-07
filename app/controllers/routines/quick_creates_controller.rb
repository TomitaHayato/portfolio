class Routines::QuickCreatesController < ApplicationController
  def create
    routine_template = current_user.quick_routine_template || current_user.create_quick_routine_template!
    new_routine      = current_user.routines.quick_build(routine_template)

    if new_routine.save
      new_routine.make_first_task
      redirect_to routine_path(new_routine), notice: 'ルーティンを作成しました'
    else
      flash.now[:alert] = 'ルーティンの作成に失敗しました'
      render turbo_stream: turbo_stream.update('flash', partial: 'shared/flash')
    end
  end
end
