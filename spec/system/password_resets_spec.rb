require 'rails_helper'

RSpec.describe "PasswordResets", type: :system do
  let!(:user) { create(:user, :for_system_spec) }

  it 'ユーザー新規登録ページからパスワードリセット申請画面に遷移できる' do
    visit new_user_path
    click_on 'パスワードをお忘れの方はこちら'

    expect(page).to have_current_path(new_password_reset_path)
    expect(page).to have_selector('input[id="email"]')
  end

  it 'ログインページからパスワードリセット申請画面に遷移できる' do
    visit login_path
    click_on 'パスワードをお忘れの方はこちら'

    expect(page).to have_current_path(new_password_reset_path)
    expect(page).to have_selector('input[id="email"]')
  end
end
