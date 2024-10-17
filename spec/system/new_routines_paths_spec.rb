require 'rails_helper'

RSpec.describe "NewRoutinesPaths", type: :system do
  context 'ログイン前' do
    it 'アクセスできない' do
      login_failed_check(new_routine_path)
    end
  end

  context 'ログイン後' do
    let!(:user) { create(:user, :for_system_spec) }

    before do
      login_as(user)
      visit new_routine_path
    end

    it ' ページが正しく表示される' do
      expect(page).to have_current_path(new_routine_path)
      expect(page).to have_selector('h1', text: 'ルーティン新規作成')
    end

    describe 'フォームに関するテスト' do
      let!(:title_form)       { find('#routine_title') }
      let!(:description_form) { find('#routine_description') }
      let!(:start_time_form)  { find('#routine_start_time') }
      let!(:submit_btn)       { find('input[type="submit"]') }

      context '正しい値を入力' do
        it 'ルーティンを作成できる => ルーティン詳細ページに遷移' do
          title_form.set('タイトル1')
          description_form.set('説明文1')
          start_time_form.set('07:00')
          submit_btn.click
          sleep 1

          expect(page).to have_current_path(routine_path(user.routines.last))
          expect(page).to have_content('作成したルーティンにタスクを追加しましょう！')
          expect(page).to have_selector('h1', text: 'タイトル1')
        end
      end

      context '不正な値を入力' do
        it '作成に失敗 => ルーティン作成ページに遷移' do
          submit_btn.click
          sleep 1

          expect(page).to have_current_path(new_routine_path)
          expect(page).to have_selector('h1', text: 'ルーティン新規作成')
          expect(page).to have_content('入力エラー')
          expect(page).to have_content('タイトルを入力してください')
        end
      end
    end
    
    describe 'フォーム以外の要素' do
      it '「キャンセル」でマイページに遷移' do
        click_on 'キャンセル'
        expect(page).to have_current_path(my_pages_path)
      end

      it '「Myルーティン一覧へ」でルーティン一覧ページに遷移' do
        click_on 'Myルーティン一覧へ'
        expect(page).to have_current_path(routines_path)
      end
    end
  end

end
