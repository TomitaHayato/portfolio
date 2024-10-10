class MyPagesController < ApplicationController
  def index
    @routine = current_user.routines.includes(:tasks).find_by(is_active: true)
    @experience_data_all = make_tag_point_hash(current_user.user_tag_experiences.includes(:tag))
    @experience_data_month = make_tag_point_hash(current_user.user_tag_experiences.includes(:tag).recent_one_month)
    @experience_data_week = make_tag_point_hash(current_user.user_tag_experiences.includes(:tag).recent_one_week)
    # p "all:#{@experience_data_all} month#{@experience_data_month} week#{@experience_data_week}"

    flash.now[:notice] = '新たな称号を獲得しました！' if current_user.reward_get_check
  end

  private

  def make_tag_point_hash(experience_collection)
    tag_point_hash = Hash.new
    experience_collection.each do |experience|
      tag = experience.tag
      tag_point_hash[tag.name] ||= 0
      tag_point_hash[tag.name] += experience.experience_point
    end
    tag_point_hash
  end
end
