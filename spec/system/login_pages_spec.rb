require 'rails_helper'

RSpec.describe "LoginPages", type: :system do
  let!(:user) { create(:user, :for_system_spec) }
  
  it 'ログインページに遷移できる' do
    visit login_path
    expect(page).to have_current_path(login_path)
  end

  describe 'ログインページに関するテスト' do
    before do
      visit login_path
    end

    let(:email_form) { find('#email') }
    let(:password_form) { find('#password') }
    let(:submit_btn) { find('input[type="submit"]') }

    context 'フォームに不正な値を入力' do
      it 'フォームに情報を入力してログインできる' do
        email_form.fill_in with: user.email
        password_form.fill_in with: 'password'
        submit_btn.click
        expect(page).to have_current_path(my_pages_path)
        expect(page).to have_content(user.name)
      end
    end

    context 'フォームに不正な値を入力' do
      it 'ログインに失敗し、login_pathに戻る' do
        email_form.fill_in with: "noexist@example.com"
        password_form.fill_in with: 'password'
        submit_btn.click

        expect(page).to have_current_path(login_path)
        expect(page).to have_content('ログインできませんでした。')
      end
    end

    describe 'ログインフォーム以外の要素' do
      it 'ヘッダーが表示されている' do
        expect(page).to have_selector('#before-login-header')
      end

      it 'LINEログインボタンが表示されている' do
        expect(page).to have_selector('#line_login_btn')
      end

      it 'キャンセルでroot_pathに戻る' do
        click_on 'キャンセル'
        expect(page).to have_current_path(root_path)
      end

      it '新規登録ページリンクをクリックで、新規登録ページに遷移できる' do
        click_on '新規登録ページへ'
        expect(page).to have_current_path(new_user_path)
      end

      it 'パスワードリセットフォームへ遷移できる' do
        click_on 'パスワードをお忘れの方はこちら'
        expect(page).to have_current_path(new_password_reset_path)
        expect(page).to have_content('パスワードリセット申請')
      end
    end
  end
end
