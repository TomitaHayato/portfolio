require 'rails_helper'

RSpec.describe "ShowRoutines", type: :system do
  let!(:user)     { create(:user, :for_system_spec) }
  let!(:routine)  { create(:routine, user: user) }
  let!(:task)     { create(:task, routine: routine) }
  let!(:tag1)     { create(:tag) }
  let!(:tag2)     { create(:tag) }

  context 'ログイン前' do
    it 'トップページに遷移' do
      login_failed_check(routine_path(routine))
    end
  end

  context 'ログイン後' do
    before do
      login_as(user)
      visit routine_path(routine)
    end

    it 'ページに遷移できる' do
      expect(page).to have_current_path(routine_path(routine))
      expect(page).to have_selector('h1', text: routine.title)
    end

    it 'ルーティン編集画面に遷移できる' do
      click_on "routine-edit-btn-#{routine.id}"
      expect(page).to have_current_path(edit_routine_path(routine))
      expect(find('#routine_title').value).to eq routine.title
    end

    it 'ルーティンを削除できる' do
      page.accept_confirm("#{routine.title}を削除してもよろしいですか？") do
        click_on "routine-delete-btn-#{routine.id}"
      end
      expect(page).to have_current_path(routines_path)
      expect(page).to have_content("#{routine.title}を削除しました")
    end

    describe 'Taskの作成処理', js: true do
      before do
        click_on 'タスクを追加'
      end

      let!(:title_form)      { find('#task_title') }
      let!(:hour_form)       { find('#task_hour') }
      let!(:minute_form)     { find('#task_minute') }
      let!(:second_form)     { find('#task_second') }

      it '表示が正常にされている' do
        expect(page).to have_selector('h1', text: 'タスク新規作成')
        expect(page).to have_selector('#task-form-for-new')
        expect(hour_form.value).to eq '00'
        expect(minute_form.value).to eq '01'
        expect(second_form.value).to eq '00'

        expect(page).to have_selector("input[id='task_tag_ids_#{tag1.id}']")
        expect(page).to have_selector("input[id='task_tag_ids_#{tag2.id}']")
        expect(page).to have_content(tag1.name)
        expect(page).to have_content(tag2.name)
      end

      context 'フォームに正しい値を入力' do
        it 'タスクを作成できる' do
          title_form.set('タスク１')
          hour_form.set('01')
          minute_form.set('10')
          second_form.set('11')
          find("input[id='task_tag_ids_#{tag1.id}']").click
          find("input[id='task_tag_ids_#{tag2.id}']").click
          click_on '登録する'
          sleep 0.1

          expect(page).to have_current_path(routine_path(routine))
          expect(page).to have_selector("#task_#{routine.tasks.last.id}")
          expect(page).to have_content(tag1.name)
          expect(page).to have_content(tag2.name)
        end
      end

      context 'フォームに不正な値を入力' do
        it 'タスク作成に失敗 => エラーメッセージを表示' do
          title_form.set('')
          hour_form.set('00')
          minute_form.set('00')
          second_form.set('00')
          click_on '登録する'
          sleep 0.1

          expect(page).to have_current_path(routine_path(routine))
          expect(page).to have_content('入力エラー')
          expect(page).to have_content('タイトルを入力してください')
          expect(page).to have_content('目安時間は1以上の整数を入力してください')
        end
      end
    end

    describe 'Taskの編集処理', js: true do
      before do
        click_on "edit_task_btn_#{task.id}"
      end

      let!(:title_form)      { find('#task_title') }
      let!(:hour_form)       { find('#task_hour') }
      let!(:minute_form)     { find('#task_minute') }
      let!(:second_form)     { find('#task_second') }

      context '正しい値を入力' do
        it 'タスク情報を更新できる' do
          title_form.set('タスク2')
          hour_form.set('02')
          minute_form.set('03')
          second_form.set('04')
          find("input[id='task_tag_ids_#{tag1.id}']").click
          find("input[id='task_tag_ids_#{tag2.id}']").click
          click_on '更新する'
          sleep 0.1

          expect(page).to have_current_path(routine_path(routine))

          expect(page).to have_selector("#task_#{task.id}")
          task_zone = find("#task_#{task.id}")
          
          expect(task_zone).to have_selector('h1', text: 'タスク2')
          expect(task_zone).not_to have_content(task.title)

          expect(task_zone).to have_content(tag1.name)
          expect(task_zone).to have_content(tag2.name)
          
          expect(task_zone).to have_content('02h')
          expect(task_zone).to have_content('03m')
          expect(task_zone).to have_content('04s')
        end
      end
    end

    describe 'タスク削除処理' do
      it 'タスクを削除できる' do
        click_on "task-delete-btn-#{task.id}"

        expect(page).to have_current_path(routine_path(routine))
        expect(page).to have_content("タスクを削除しました。(タスク名：#{task.title})")
        expect(page).not_to have_selector("#task_#{task.id}")
      end
    end
  end
end
