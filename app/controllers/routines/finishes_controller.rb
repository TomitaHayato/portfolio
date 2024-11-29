class Routines::FinishesController < ApplicationController
  skip_before_action :playing_task_sesison_reset
  before_action      :block_if_no_session

  def index
    current_user.add_complete_routines_count
    # 経験値情報をuser_tag_experiencesテーブルに保存
    user_get_tag_experiences(session[:experience_log])
                                                # レベルアップ処理
    flash.now[:notice] = 'レベルアップしました！！' if current_user.level_up_check
    
    @tag_point_hash = make_tag_point_hash(session[:experience_log])
  end

  private

  # routines_playsコントローラを介さずにアクセスできない
  def block_if_no_session
    redirect_to my_pages_path, alert: 'ページに遷移できませんでした' if session[:playing_task_num].nil?
  end

  # 獲得した経験値情報から、UserTagExperiencesテーブルに情報を追加していく
  def user_get_tag_experiences(experience_log)
    experience_log.each do |tag_id, point|
      UserTagExperience.create!(user_id: current_user.id, tag_id: tag_id.to_i, experience_point: point.to_i)
    end
  end

  # { Tag名: 獲得Exp }を作成
  # viewでどのタグの経験値をどのくらい獲得したかを表示するために使用。
  def make_tag_point_hash(experience_log)
    tag_point_hash = Hash.new
    tags_hash      = Tag.all.index_by(&:id) # key=id, value=Tagモデルインスタンスとなるハッシュを作成。ハッシュにしてクエリ削減
    
    experience_log.each do |tag_id, point|
      tag                      = tags_hash[tag_id.to_i]
      tag_point_hash[tag.name] = point
    end

    tag_point_hash
  end
end

