class WeeklyReportMailer < ApplicationMailer
  def notify_email
    @user = params[:user]
    now   = params[:now]

    @total_exps            = @user.user_tag_experiences.weekly(now).pluck(:experience_point).sum # 獲得経験値の合計
    achieve_records        = @user.achieve_records.weekly(now)
    @achieve_routines_size = achieve_records.size                  # ルーティン達成数
    @routine_titles        = achieve_records.pluck(:routine_title) # 達成したルーティンのタイトル一覧

    mail(to:      @user.email,
         subject: '[Morning Forest] 週間レポート')
  end
end
