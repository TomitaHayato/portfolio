class MyPagesController < ApplicationController
  def index
    @routine               = current_user.routines.includes(tasks: :tags).find_by(is_active: true)
    # 獲得経験値
    user_tag_experiences   = current_user.user_tag_experiences.includes(:tag)
    @experience_data_all   = user_tag_experiences.make_tag_point_hash # { タグ: exp }形式のハッシュ
    @experience_data_month = user_tag_experiences.recent_one_month.make_tag_point_hash
    @experience_data_week  = user_tag_experiences.recent_one_week.make_tag_point_hash
    # p "all:#{@experience_data_all} month:#{@experience_data_month} week:#{@experience_data_week}"
    @exp_to_next_level     = current_user.exp_to_next_level

    flash.now[:notice] = '新たな称号を獲得しました！' if current_user.reward_get_check
  end
end
