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
    end
  end

  describe 'header/footerのテスト' do
    let(:user)  { create(:user, :for_system_spec) }
    let!(:path) { new_user_path }

    context 'ログイン前' do
      it_behaves_like 'ログイン前Header/Footerテスト'
    end

    context 'ログイン後' do
      it_behaves_like 'ログイン後Header/Footerテスト'
    end
  end

  describe 'ユーザーの新規登録フォームに関するテスト' do
    it 'フォームが表示されている' do
      expect(page).to have_selector '#user_name'
      expect(page).to have_selector '#user_email'
      expect(page).to have_selector '#user_password'
      expect(page).to have_selector '#user_password_confirmation'
      expect(page).to have_selector 'input[type="submit"]'
    end

    let(:name_form) { find('#user_name') }
    let(:email_form) { find('#user_email') }
    let(:password_form) { find('#user_password') }
    let(:password_confirmation_form) { find('#user_password_confirmation') }
    let(:submit_btn) { find('input[type="submit"]') }

    context 'フォームに正常値を入力' do
      it '新規登録に成功する＋マイページに遷移する' do
        # 登録前のDB
        user_size_prev = User.all.size
        # フォーム送信
        name_form.set                  user.name
        email_form.set                 user.email
        password_form.set              user.password
        password_confirmation_form.set user.password_confirmation
        submit_btn.click
        # ページ遷移
        expect(page).to have_current_path my_pages_path
        expect(page).to have_content      'ユーザーを新しく追加しました'
        expect(page).to have_content      user.name
        #DB
        expect(User.all.size).to  eq user_size_prev + 1
        user_new = User.last
        expect(user_new.name).to  eq user.name
        expect(user_new.email).to eq user.email
      end
    end

    context 'フォームに不正な値を入力' do
      it 'ユーザー作成に失敗し、エラーメッセージが表示される' do
        # 登録前のDB
        user_size_prev = User.all.size
        # フォーム送信
        submit_btn.click
        #ページ
        expect(page).to have_current_path new_user_path
        expect(page).to have_content      'ユーザーの作成に失敗しました'
        expect(page).to have_content      '入力エラー'
        expect(page).to have_content      '名前を入力してください'
        #DB
        expect(User.all.size).to eq user_size_prev
      end
    end
  end

  describe 'フォーム以外の要素' do
    it 'キャンセルでroot_pathに遷移できる' do
      click_on 'キャンセル'
      expect(page).to have_current_path(root_path)
    end

    it 'LINEログインボタンが表示' do
      expect(page).to have_selector '#line-login-btn'
    end

    it 'ログインページへ遷移できる' do
      click_on 'ログインページへ'
      expect(page).to have_current_path(login_path)
    end

    it 'パスワードリセットフォームへ遷移できる' do
      click_on 'パスワードをお忘れの方はこちら'
      expect(page).to have_current_path new_password_reset_path
      expect(page).to have_content      'パスワードリセット申請'
    end
  end
end
