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

  it '申請フォームにアドレスを入力すると、パスワードリセットトークンが作成される' do
    visit new_password_reset_path

    find('input[id="email"]').set(user.email)
    click_on '申請'

    expect(page).to have_current_path(root_path)
    expect(page).to have_content('メールが送信されました。')
    
    user.reload
    expect(user.reset_password_token).not_to be_nil

    visit edit_password_reset_path(user.reset_password_token)
    expect(page).to have_current_path(edit_password_reset_path(user.reset_password_token))
    expect(page).to have_selector('#user_password')
    expect(page).to have_selector('#user_password_confirmation')

    fill_in 'user_password', with: 'new_pass'
    fill_in 'user_password_confirmation', with: 'new_pass'
    click_on '変更する'

    expect(page).to have_current_path(root_path)
    expect(page).to have_content('パスワードが正常に更新されました。')
  end
end
