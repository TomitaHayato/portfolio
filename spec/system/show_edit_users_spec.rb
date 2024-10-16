require 'rails_helper'

RSpec.describe "ShowEditUsers", type: :system do
  let!(:user) { create(:user, :for_system_spec) }
  let!(:user_other) { create(:user, :for_system_spec) }

  describe 'ユーザー詳細画面のテスト' do
    context 'ログイン前' do
      before do
        visit user_path(user)
      end

      it 'ページにアクセスできず、ログイン画面に遷移' do
        expect(page).to have_current_path(login_path)
        expect(page).to have_content('ログインしてください')
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
    end
  end
end
