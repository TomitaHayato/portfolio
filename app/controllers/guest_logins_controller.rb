class GuestLoginsController < ApplicationController
  skip_before_action :require_login

  def create
    random_value = SecureRandom.alphanumeric(10) #ランダムな文字列を生成 => email, passwordに使用

    user = User.create!(
      name:                  "ゲストユーザー",
      email:                 "#{random_value}@email.com",
      password:              random_value.to_s,
      password_confirmation: random_value.to_s,
      role:                  "guest"
    )
    user.make_first_routine.make_first_task
    user.create_quick_routine_template!

    login(user.email, random_value)

    redirect_to my_pages_path, notice: "ゲストログインしました。"
  end
end
