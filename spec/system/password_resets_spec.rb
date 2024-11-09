require 'rails_helper'

RSpec.describe "PasswordResets", type: :system do
  let!(:user) { create(:user, :for_system_spec) }

  it 'ユーザー新規登録ページからパスワードリセット申請画面に遷移できる' do
    visit new_user_path
    click_on 'パスワードをお忘れの方はこちら'

    expect(page).to have_current_path(new_password_reset_path)
  end

  it 'ログインページからパスワードリセット申請画面に遷移できる' do
    visit login_path
    click_on 'パスワードをお忘れの方はこちら'

    expect(page).to have_current_path(new_password_reset_path)
  end
  
  describe 'フォームに関するテスト' do
    before do
      visit new_password_reset_path
    end

    it 'フォームが正常に表示される' do
      expect(page).to have_selector 'input[id="email"]'
      expect(page).to have_selector 'input[type="submit"][value="申請"]'
    end

    describe 'フォームに入力後の処理' do
      let!(:email_form) { find('input[id="email"]') }
      let!(:submit_btn) { find('input[type="submit"][value="申請"]') }

      context 'DBに存在するメールアドレスを入力' do
        before do
          email_form.set(user.email)
          submit_btn.click
        end

          it 'トップページに遷移' do
          expect(page).to           have_current_path(root_path)
          expect(find('#flash')).to have_content 'メールが送信されました。'
        end
      end

      context 'DBに存在するメールアドレスを入力' do
        before do
          email_form.set(user.email + 'aaa')
          submit_btn.click
        end

        it 'トップページに遷移' do
          expect(page).to           have_current_path(root_path)
          expect(find('#flash')).to have_content 'メールが送信されました。'
        end
      end
    end
  end

  describe 'header/footerのテスト' do
    context 'ログイン前' do
      before do
        visit new_password_reset_path
      end

      it_behaves_like 'ログイン前Header/Footerテスト'
    end

    context 'ログイン後' do
      before do
        login_as(user)
        visit new_password_reset_path
      end

      it_behaves_like 'ログイン後Header/Footerテスト'
    end
  end
end
