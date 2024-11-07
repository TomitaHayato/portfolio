require 'rails_helper'

RSpec.describe "NewUserPath", type: :system do
  before do
    visit new_user_path
  end

  let(:user) { build(:user) }
  let(:user_no_attribute) { build(:user, :no_attribute) }

  describe 'ページに遷移できるか' do
    it '新規登録ページに遷移できている' do
      expect(page).to have_current_path(new_user_path)
      expect(page).to have_selector('#before-login-header')
    end
  end

  describe 'ユーザーの新規登録フォームに関するテスト' do
    let(:name_form) { find('#user_name') }
    let(:email_form) { find('#user_email') }
    let(:password_form) { find('#user_password') }
    let(:password_confirmation_form) { find('#user_password_confirmation') }
    let(:submit_btn) { find('input[type="submit"]') }

    context 'フォームに正常値を入力' do
      it '新規登録に成功する＋マイページに遷移する' do
        name_form.fill_in with: user.name
        email_form.fill_in with: user.email
        password_form.fill_in with: user.password
        password_confirmation_form.fill_in with: user.password_confirmation
        submit_btn.click

        expect(page).to have_current_path(my_pages_path)
        expect(page).to have_content('ユーザーを新しく追加しました')
        expect(page).to have_content(user.name)
      end
    end

    context 'フォームに不正な値を入力' do
      it 'ユーザー作成に失敗し、エラーメッセージが表示される' do
        submit_btn.click

        expect(page).to have_current_path(new_user_path)
        expect(page).to have_content('ユーザーの作成に失敗しました')
        expect(page).to have_content('入力エラー')
        expect(page).to have_content('名前を入力してください')
      end
    end
  end

  describe 'フォーム以外の要素' do
    it 'キャンセルでroot_pathに遷移できる' do
      click_on 'キャンセル'
      expect(page).to have_current_path(root_path)
    end

    it 'ログインページへ遷移できる' do
      click_on 'ログインページへ'
      expect(page).to have_current_path(login_path)
    end

    it 'パスワードリセットフォームへ遷移できる' do
      click_on 'パスワードをお忘れの方はこちら'
      expect(page).to have_current_path(new_password_reset_path)
      expect(page).to have_content('パスワードリセット申請')
    end
  end
end
