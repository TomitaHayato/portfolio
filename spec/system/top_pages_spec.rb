require 'rails_helper'

RSpec.describe "TopPages", type: :system do
  let!(:user) { create(:user) }

  describe 'トップページ（root_path）のUI' do
    context 'ユーザーログイン前' do
      before do
        visit root_path
      end

      it 'トップページにログイン前のヘッダーが表示されている' do
        expect(page).to have_link('ログイン')
        expect(page).to have_link('header-logo')
      end

      it 'トップページにアプリタイトルが表示されている' do
        expect(page).to have_selector('h1', text: 'Morning')
      end

      it 'トップページにアプリの使い方が表示されている' do
        expect(page).to have_selector('h1', text: 'アプリの使い方')
      end
    end
  end
end
