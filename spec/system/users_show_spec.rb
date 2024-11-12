require 'rails_helper'

RSpec.describe "ShowUsers", type: :system do
  let!(:user) { create(:user, :for_system_spec) }
  let!(:user_other) { create(:user, :for_system_spec) }

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

    it 'ページにアクセスできる' do
      expect(page).to have_current_path(user_path(user))
    end
    
    describe 'header/footerのテスト' do
      context 'ログイン後' do
        it_behaves_like 'ログイン後Header/Footerテスト'
      end
    end

    describe 'パンくず' do
      let!(:breadcrumb_container) { find('.breadcrumbs-container-custom') }

      it '正しく表示される' do
        expect(breadcrumb_container).to have_selector "a[href='#{my_pages_path}']"
        expect(breadcrumb_container).to have_content  'プロフィール'
      end

      it 'マイページに遷移できる' do
        breadcrumb_container.find("a[href='#{my_pages_path}']").click
        expect(page).to have_current_path my_pages_path
      end
    end

    it 'プロフィール画面にアクセスできる' do
      expect(page).to have_content  user.name
      expect(page).to have_content  user.email
      expect(page).to have_content  user.complete_routines_count
      expect(page).to have_selector "#avatar-#{user.id}"
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
  end
end