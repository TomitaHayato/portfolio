class PasswordResetsController < ApplicationController
  skip_before_action :require_login

  def new; end

  # パスワードリセットのリクエスト。
  # ユーザーがリセットパスワードフォームにメールアドレスを入力して送信したときにここにきます。
  def create 
    @user = User.find_by_email(params[:email])

    if @user && !Rails.env.test?
      # この行で、リセットパスワードの方法（ランダムなトークン付きのURL）を記載したメールがユーザーに送信されます。
      @user.deliver_reset_password_instructions!
    end
 
    # メールが見つかったかどうかにかかわらず、指示が送信されたことをユーザーに知らせます。
    # システムに登録されているメールアドレスの有無について攻撃者に情報を漏らさないためです。
    redirect_to(root_path, :notice => 'メールが送信されました。')
  end

  # これはパスワードリセットフォームです。
  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end
  end

  # ユーザーがパスワードリセットフォームを送信したときに実行されるアクションです。
  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end

    # 次の行は、パスワード確認のバリデーションを有効にします
    @user.password_confirmation = params[:user][:password_confirmation]
    # 次の行は、一時的なトークンをクリアし、パスワードを更新します
    if @user.change_password(params[:user][:password])
      redirect_to(root_path, :notice => 'パスワードが正常に更新されました。')
    else
      render :action => "edit"
    end
  end
end
