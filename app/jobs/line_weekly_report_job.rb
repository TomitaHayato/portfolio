class LineWeeklyReportJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false # Jobが失敗した際、再試行せず破棄
  include Rails.application.routes.url_helpers
  include LineTextPushRequest

  def perform(user, now)
    # whereで絞り込んでいるため、weeklyの処理でN+1問題
    total_exps            = user.user_tag_experiences.weekly(now).pluck(:experience_point).sum # 獲得経験値の合計
    achieve_records       = user.achieve_records.weekly(now)
    achieve_routines_size = achieve_records.size # ルーティン達成数
    routine_titles        = achieve_records.pluck(:routine_title) # 達成したルーティンのタイトル一覧

    text =  "今週の週間レポートです！\n\n"
    text << "獲得経験値： #{total_exps}\n"
    text << "　　達成数： #{achieve_routines_size}\n\n"
    text << make_routine_titles_str(routine_titles)
    text << "\n来週も頑張りましょう！！"

    uid  = user.authentications.find_by(provider: 'line').uid

    request_line_push_end_point(uid, text)
  end

  private

  # 達成したルーティンを箇条書きで表示するための文字列を作成
  def make_routine_titles_str(routine_titles)
    str = "今週達成したルーティン\n"
    return str if routine_titles.empty?

    routine_titles.each do |title|
      str += "・#{title}\n"
    end

    str
  end
end
