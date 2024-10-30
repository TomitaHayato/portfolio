require 'rails_helper'

RSpec.describe "ShowEditUsers", type: :system do
  let!(:user) { create(:user, :for_system_spec) }
  let!(:user_other) { create(:user, :for_system_spec) }

  describe 'ユーザー詳細画面のテスト' do
    context 'ログイン前' do
      it 'ページにアクセスできず、ログイン画面に遷移' do
        login_failed_check(user_path(user))
      end
    end

    context 'ログイン後' do
      before do
        login_as(user)
        visit user_path(user)
      end

      it '自分のプロフィール画面にアクセスできる' do
        expect(page).to have_current_path(user_path(user))
        expect(page).to have_content(user.name)
        expect(page).to have_content(user.email)
        expect(page).to have_selector("#avatar-#{user.id}")
      end

      it '他のユーザーのプロフィール画面にアクセスできない' do
        visit user_path(user_other.id)
        expect(page).to have_content(user.name)
        expect(page).to have_content(user.email)
      end

      it 'ユーザー編集画面に遷移できる' do
        click_on 'プロフィールを編集'
        expect(page).to have_current_path(edit_user_path(user))
        expect(find('#user_email').value).to eq user.email
      end

      it '「戻る」でマイページに遷移できる' do
        click_on "←マイページ"
        expect(page).to have_current_path(my_pages_path)
      end
    end
  end

  describe 'ユーザー編集画面のテスト' do
    context 'ログイン前' do
      it 'アクセスに失敗し、ログイン画面に遷移する' do
        login_failed_check(edit_user_path(user))
      end
    end

    context 'ログイン後' do
      before do
        login_as(user)
        visit edit_user_path(user)
      end

      describe '編集フォームに関するテスト' do
        let!(:avatar_form) { find('#user_avatar') }
        let!(:name_form)   { find('#user_name') }
        let!(:email_form)  { find('#user_email') }
        let!(:submit_btn)  { find('input[type="submit"]') }

        it 'フォームが正しく表示されている' do
          expect(page).to have_selector("[id = 'preview avatar-#{user.id}']")

          expect(page).to have_selector('#user_avatar')
          expect(page).to have_selector('#user_name')
          expect(find('#user_name').value).to eq user.name
          expect(page).to have_selector('#user_email')
          expect(find('#user_email').value).to eq user.email
        end

        context 'フォームに正しい値を入力' do
          it 'ユーザー情報の更新に成功 => プロフィール画面に遷移' do
            name_form.set('new name')
            email_form.set('new@email.com')
            submit_btn.click

            expect(page).to have_current_path(user_path(user))
            expect(page).to have_content('プロフィールを更新しました')
            expect(page).to have_content('new name')
            expect(page).to have_content('new@email.com')
          end
        end

        context 'フォームに不正な値を入力' do
          it 'ユーザー情報の更新に失敗 => プロフィール編集画面に戻る' do
            name_form.set('')
            email_form.set('')
            submit_btn.click

            expect(page).to have_current_path(edit_user_path(user))
            expect(page).to have_content('入力エラー')
            expect(page).to have_content('メールアドレスを入力してください')
            expect(page).to have_content('名前を入力してください')
          end
        end
      end

      describe 'フォーム以外の要素のテスト' do
        it '「キャンセル」でプロフィール画面に戻れる' do
          click_on 'キャンセル'
          expect(page).to have_current_path(user_path(user))
        end
      end
    end
  end
end
