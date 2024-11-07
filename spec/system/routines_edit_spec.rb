require 'rails_helper'

RSpec.describe "EditRoutines", type: :system do
  let!(:user)     { create(:user, :for_system_spec) }
  let!(:routine)  { create(:routine, user: user) }

  context 'ログイン前' do
    it 'トップページに遷移' do
      login_failed_check(edit_routine_path(routine))
    end
  end

  context 'ログイン後' do
    before do
      login_as(user)
      visit edit_routine_path(routine)
    end

    let!(:title_form)       { find('#routine_title') }
    let!(:description_form) { find('#routine_description') }
    let!(:start_time_form)  { find('#routine_start_time') }
    let!(:submit_btn)       { find('input[type="submit"]') }

    it 'ページに遷移できる' do
      expect(page).to have_current_path(edit_routine_path(routine))
      expect(title_form.value).to eq routine.title
    end

    context '正しい値を入力' do
      it 'ルーティン情報を編集できる' do
        title_form.set('new_タイトル')
        description_form.set('new_説明文')
        start_time_form.set('10:30')
        submit_btn.click
        sleep 0.1

        expect(page).to have_current_path(routine_path(routine))
        expect(page).to have_content('ルーティンを更新しました')
        expect(page).to have_selector('h1', text: 'new_タイトル')
      end
    end

    context '不正な値を入力' do
      it '更新に失敗 => ルーティン編集ページに遷移' do
        title_form.set('')
        submit_btn.click

        expect(page).to have_current_path(edit_routine_path(routine))
        expect(page).to have_content('タイトルを入力してください')
        expect(title_form.value).to eq ""
      end
    end

    it '「ルーティン一覧へ」でルーティン一覧画面に遷移する' do
      click_on 'ルーティン一覧へ'
      expect(page).to have_current_path(routines_path)
    end
  end
end
