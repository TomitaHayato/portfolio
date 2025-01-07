class Routines::FinishesController < ApplicationController
  skip_before_action :playing_task_sesison_reset
  before_action      :block_if_no_session

  def index
    current_user.add_complete_routines_count

    # 経験値情報をuser_tag_experiencesテーブルに保存
    current_user.get_experiences(session[:exp_log])

    # レベルアップ処理
    flash.now[:notice] = 'レベルアップしました！！' if current_user.level_up_check

    @tag_point_hash = make_tag_point_hash(session[:exp_log])
  end

  private

  # routines_playsコントローラを介さずにアクセスできない
  def block_if_no_session
    redirect_to my_pages_path, alert: 'ページに遷移できませんでした' if session[:task_index].nil?
  end

  # viewで「どのタグの経験値をどのくらい獲得したか」表示する
  def make_tag_point_hash(exp_log)
    tag_point_hash = {}
    tags_hash      = Tag.all.index_by(&:id) # { id: Tagモデルインスタンス, ... } ハッシュを作成。ハッシュにしてクエリ削減

    exp_log.each do |tag_id, point|
      tag                      = tags_hash[tag_id.to_i]
      tag_point_hash[tag.name] = point
    end

    tag_point_hash # { Tag名: 獲得Exp }
  end
end
