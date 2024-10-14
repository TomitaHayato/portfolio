require 'rails_helper'

RSpec.describe "TopPages", type: :system do

  describe 'トップページ（root_path）に関するテスト' do
    context 'ユーザーログイン前' do
      before do
        visit root_path
      end
      
      describe 'トップページのヘッダーに関するテスト' do
        it 'トップページのヘッダーにログインボタンが表示される' do
          expect(page).to have_link('ログイン')
          click_link 'ログイン'
          expect(page).to have_current_path(login_path)
        end

        it 'トップページのヘッダーに新規登録ボタンが表示される' do
          expect(page).to have_link('新規登録')
          click_link '新規登録'
          expect(page).to have_current_path(new_user_path)
        end

        it 'トップページのヘッダーにヘッダーロゴが表示される' do
          expect(page).to have_link('header-logo')
          find('#header-logo').click
          expect(page).to have_current_path(root_path)
        end

        it 'トップページのヘッダーにお試しログインボタンが表示される' do
          expect(page).to have_link('お試し')
          click_link 'お試し'
          expect(page).to have_current_path(my_pages_path)
          expect(page).to have_content('ゲストログインしました。')
        end
      end

      describe 'トップページのメインコンテンツに関するテスト' do
        it 'トップページにアプリタイトルが表示されている' do
          expect(page).to have_selector('h1', text: 'Morning')
        end

        it 'トップページにアプリの使い方が表示されている' do
          expect(page).to have_selector('h1', text: 'アプリの使い方')
        end
      end

      describe 'トップページのフッターに関するテスト' do
        it 'トップページのフッターにプライバシーポリシーリンクが表示されている' do
          expect(page).to have_link('プライバシーポリシー')
          click_link('プライバシーポリシー')
          expect(page).to have_current_path(policy_path)
        end

        it 'トップページのフッターにプライバシーポリシーリンクが表示されている' do
          expect(page).to have_link('利用規約')
          click_link('利用規約')
          expect(page).to have_current_path(terms_path)
        end
      end
    end
  end
end
