class QuickRoutineTemplatesController < ApplicationController
  before_action :create_template?

  def update
    @quick_routine_template = current_user.quick_routine_template

    redirect_to routines_path, notice: '1click作成用テンプレートを更新しました' if @quick_routine_template.update(quick_routine_template_params)
  end

  private

  def quick_routine_template_params
    params.require(:quick_routine_template).permit(:title, :description, :start_time)
  end

  # Routineテンプレートがない場合作成
  def create_template?
    return false if current_user.quick_routine_template

    current_user.create_quick_routine_template!
  end
end
