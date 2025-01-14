class MyPagesController < ApplicationController
  def index
    @routine               = current_user.routines.includes(tasks: :tags).find_by(is_active: true)
    # 獲得経験値
    user_tag_experiences   = current_user.user_tag_experiences.includes(:tag)
    empty_exp_hash         = Tag.make_empty_exp_hash
    @experience_data_all   = user_tag_experiences.make_tag_point_hash(empty_exp_hash) # { タグ: exp }形式のハッシュ
    @experience_data_month = user_tag_experiences.recent_one_month.make_tag_point_hash(empty_exp_hash)
    @experience_data_week  = user_tag_experiences.recent_one_week.make_tag_point_hash(empty_exp_hash)
    # 次のレベルまでに必要な経験値
    @exp_to_next_level     = current_user.exp_to_next_level
    # 称号獲得処理
    flash.now[:notice] = '新たな称号を獲得しました！' if current_user.reward_get_check
  end
end
