class MyPagesController < ApplicationController
  def index
    @routine               = current_user.routines.includes(tasks: :tags).find_by(is_active: true)
    # 獲得経験値
    user_tag_experiences    = current_user.user_tag_experiences.includes(:tag)
    @experience_data_all   = make_tag_point_hash(user_tag_experiences) #{ タグ: exp }形式のハッシュ
    @experience_data_month = make_tag_point_hash(user_tag_experiences.recent_one_month)
    @experience_data_week  = make_tag_point_hash(user_tag_experiences.recent_one_week)
    #   p "all:#{@experience_data_all} month#{@experience_data_month} week#{@experience_data_week}"
    @exp_to_next_level     = current_user.exp_to_next_level

    flash.now[:notice] = '新たな称号を獲得しました！' if current_user.reward_get_check
  end

  private

  def make_tag_point_hash(exp_collection)
    tag_point_hash = Hash.new
    exp_collection.each do |experience|
      tag = experience.tag
      tag_point_hash[tag.name] ||= 0
      tag_point_hash[tag.name] += experience.experience_point
    end
    tag_point_hash.sort_by{ |k, v| -v }.to_h
  end
end
