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
    describe 'header/footerのテスト' do
      let!(:path) { edit_routine_path(routine) }
  
      context 'ログイン後' do
        it_behaves_like 'ログイン後Header/Footerテスト'
      end
    end

    before do
      login_as(user)
      visit edit_routine_path(routine)
    end

    it 'ページに遷移できる' do
      expect(page).to have_current_path(edit_routine_path(routine))
    end

    describe 'パンくず' do
      let!(:breadcrumb_container) { find('.breadcrumbs-container-custom') }

      it '正しく表示される' do
        expect(breadcrumb_container).to have_selector "a[href='#{my_pages_path}']"
        expect(breadcrumb_container).to have_selector "a[href='#{routines_path}']"
        expect(breadcrumb_container).to have_selector "a[href='#{routine_path(routine)}']"
        expect(breadcrumb_container).to have_content  '編集'
      end

      it 'マイページに遷移できる' do
        breadcrumb_container.find("a[href='#{my_pages_path}']").click

        expect(page).to have_current_path my_pages_path
      end

      it 'routines_pathに遷移できる' do
        breadcrumb_container.find("a[href='#{routines_path}']").click

        expect(page).to have_current_path routines_path
      end

      it 'routine_pathに遷移できる' do
        breadcrumb_container.find("a[href='#{routine_path(routine)}']").click

        expect(page).to have_current_path routine_path(routine)
      end
    end

    describe 'フォームに関するテスト' do
      let!(:title_form)       { find('#routine_title') }
      let!(:description_form) { find('#routine_description') }
      let!(:start_time_form)  { find('#routine_start_time') }
      let!(:submit_btn)       { find('input[type="submit"]') }

      it 'フォームが正しく表示される' do
        expect(page).to have_selector '#routine_title'
        expect(page).to have_selector '#routine_description'
        expect(page).to have_selector '#routine_start_time'
        expect(page).to have_selector '#routine_notification_no'
        expect(page).to have_selector '#routine_notification_line'
      end

      it 'フォームに初期値が含まれている' do
        expect(title_form.value).to       eq routine.title
        expect(description_form.value).to eq routine.description
        expect(start_time_form.value).to  eq routine.start_time.strftime('%H:%M:%S') + '.000'
      end

      it '通知設定の初期値が選択されている' do
        checked_radio = find("#routine_notification_#{routine.notification}")
        expect(checked_radio).to be_checked
      end

      context '正しい値を入力' do
        it 'ルーティン情報を編集できる' do
          title_form.set('new_タイトル')
          description_form.set('new_説明文')
          start_time_form.set('10:30')
          choose('routine_notification_line')
          submit_btn.click
          sleep 0.1
          #表示の確認
          expect(page).to have_current_path(routine_path(routine))
          expect(page).to have_content('ルーティンを更新しました')
          expect(page).to have_selector('h1', text: 'new_タイトル')
          # DBの確認
          routine.reload
          expect(routine.title).to                         eq 'new_タイトル'
          expect(routine.description).to                   eq 'new_説明文'
          expect(routine.start_time.strftime('%H:%M')).to  eq '10:30'
          expect(routine.notification).to                  eq 'line'
        end
      end

      context '不正な値を入力' do
        it '更新に失敗 => ルーティン編集ページに遷移' do
          title_form.set('')
          submit_btn.click
          # 表示のテスト
          expect(page).to              have_current_path(edit_routine_path(routine))
          expect(page).to              have_content('タイトルを入力してください')
          expect(title_form.value).to  eq ''
          # DBのテスト
          expect(routine.title).not_to eq ''
        end
      end
    end

    it '「ルーティン一覧へ」リンク' do
      click_on 'ルーティン一覧へ'
      expect(page).to have_current_path(routines_path)
    end

    it '「マイページに戻る」リンク' do
      click_on 'マイページに戻る'
      expect(page).to have_current_path(my_pages_path)
    end
  end
end
