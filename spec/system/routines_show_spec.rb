require 'rails_helper'

RSpec.describe "ShowRoutines", type: :system, js: true do
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
      # taskにtag1をセット
      create(:task_tag, task: task, tag: tag1)

      login_as(user)
      visit routine_path(routine)
    end

    it 'ページに遷移できる' do
      expect(page).to have_current_path(routine_path(routine))
      expect(page).to have_selector('h1', text: routine.title)
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
        expect(breadcrumb_container).to have_selector "a[href='#{routines_path}']"
        expect(breadcrumb_container).to have_content  '詳細'
      end

      it 'my_pages_pathに遷移できる' do
        breadcrumb_container.find("a[href='#{my_pages_path}']").click
        expect(page).to have_current_path my_pages_path
      end

      it 'routines_pathに遷移できる' do
        breadcrumb_container.find("a[href='#{routines_path}']").click
        expect(page).to have_current_path routines_path
      end
    end

    it 'ルーティン情報が表示される' do
      # ルーティン情報
      expect(page).to have_content routine.title
      expect(page).to have_content routine.description
      expect(page).to have_content routine.start_time.strftime('%H:%M')
      expect(page).to have_content routine.completed_count
      # リンク
      expect(page).to have_selector "#routine-edit-btn-#{routine.id}"
      expect(page).to have_selector "#routine-delete-btn-#{routine.id}"
    end

    it 'タスク情報が表示される' do
      expect(page).to have_selector "#task-index"
      expect(page).to have_selector "#add_task_btn"
      task_field = find("#task_#{task.id}")
      # タスク情報
      expect(task_field).to have_content task.title
      expect(task_field).to have_content '00h'
      expect(task_field).to have_content '01m'
      expect(task_field).to have_content '00s'
      expect(task_field).to have_content tag1.name
      # リンク
      expect(task_field).to have_selector "#edit_task_btn_#{task.id}"
      expect(task_field).to have_selector "#task-delete-btn-#{task.id}"
      expect(task_field).to have_selector "#move-higher-btn-#{task.id}"
      expect(task_field).to have_selector "#move-lower-btn-#{task.id}"
    end

    it 'ルーティン編集画面に遷移できる' do
      click_on "routine-edit-btn-#{routine.id}"
      expect(page).to have_current_path(edit_routine_path(routine))
      expect(find('#routine_title').value).to eq routine.title
    end

    it 'ルーティンを削除できる' do
      # 削除前のDB
      routine_size_prev = user.routines.size
      # 削除ボタン
      page.accept_confirm("#{routine.title}を削除してもよろしいですか？") do
        click_on "routine-delete-btn-#{routine.id}"
      end
      #ページ
      expect(page).to have_current_path(routines_path)
      expect(page).to have_content("#{routine.title}を削除しました")
      #DB
      expect(user.routines.size).to            eq routine_size_prev - 1
      expect(Task.where(id: task.id).count).to eq 0
    end

    describe 'Taskの作成処理' do
      before do
        click_on 'タスクを追加'
      end

      # ページ更新時に、取得する要素も更新しなくてはいけない
      let!(:task_form_new)   { find('#task-form-for-new') }
      let!(:title_form)      { find('#task_title') }
      let!(:hour_form)       { find('#task_hour') }
      let!(:minute_form)     { find('#task_minute') }
      let!(:second_form)     { find('#task_second') }
      let!(:tag1_check_box) { find("input[id='task_tag_ids_#{tag1.id}']") }
      let!(:tag2_check_box) { find("input[id='task_tag_ids_#{tag2.id}']") }

      it 'フォームが表示されている' do
        #各フォーム
        expect(task_form_new).to have_selector '#task_title'
        expect(task_form_new).to have_selector '#task_hour'
        expect(task_form_new).to have_selector '#task_minute'
        expect(task_form_new).to have_selector '#task_second'
        # 目安時間の初期値
        expect(hour_form.value).to   eq '00'
        expect(minute_form.value).to eq '01'
        expect(second_form.value).to eq '00'
        # タグのセレクトボックス
        Tag.all.each do |tag|
          tag_cont = find("label[for='task_tag_ids_#{tag.id}']")
          expect(tag_cont).to have_selector "input[id='task_tag_ids_#{tag.id}']"
          expect(tag_cont).to have_content  tag.name
        end
      end

      context 'フォームに正しい値を入力' do
        it 'タスクを作成できる' do
          # 作成前のタスク数
          task_size_prev = routine.tasks.size
          # フォームから作成
          title_form.set  'タスク1'
          hour_form.set   '01'
          minute_form.set '10'
          second_form.set '11'
          tag1_check_box.click
          tag2_check_box.click
          click_on '登録する'
          sleep 0.1

          # ページ表示
          expect(page).to                have_current_path routine_path(routine)
          expect(find('#task-index')).to have_selector     "#task_#{routine.tasks.last.id}"

          task_field = find("#task_#{routine.tasks.last.id}")
          expect(task_field).to have_content 'タスク1'
          expect(task_field).to have_content '01h'
          expect(task_field).to have_content '10m'
          expect(task_field).to have_content '11s'
          expect(task_field).to have_content tag1.name
          expect(task_field).to have_content tag2.name
          # DB
          expect(routine.tasks.size).to eq(task_size_prev + 1)
          new_task = routine.tasks.last
          expect(new_task.tags).to include tag1
          expect(new_task.tags).to include tag2
        end
      end

      context 'フォームに不正な値を入力' do
        it 'タスク作成に失敗 => エラーメッセージを表示' do
          # 作成前のDB
          task_size_prev = routine.tasks.size
          task_tags_prev = TaskTag.all.size
          # フォーム送信
          title_form.set  ''
          hour_form.set   '00'
          minute_form.set '00'
          second_form.set '00'
          tag1_check_box.click
          click_on '登録する'
          sleep 0.1
          #ページ
          expect(page).to have_current_path routine_path(routine)
          task_form_new = find('#task-form-for-new') #ページ更新後の要素を再取得
          expect(task_form_new).to have_content      '入力エラー'
          expect(task_form_new).to have_content      'タイトルを入力してください'
          expect(task_form_new).to have_content      '目安時間は1以上の整数を入力してください'
          #フォーム
          minute_form = find('#task_minute') #ページ更新後の要素を再取得
          expect(minute_form.value).to eq                 '00'
          expect(task_form_new).to     have_checked_field "task_tag_ids_#{tag1.id}"
          #DB
          expect(task_size_prev).to eq routine.tasks.size
          expect(task_tags_prev).to eq TaskTag.all.size
        end
      end
    end

    describe 'Taskの編集処理', js: true do
      before do
        click_on "edit_task_btn_#{task.id}"
      end

      let!(:task_form)      { find("#task-form-for-#{task.id}")           }
      let!(:title_form)     { find('#task_title')                         }
      let!(:hour_form)      { find('#task_hour')                          }
      let!(:minute_form)    { find('#task_minute')                        }
      let!(:second_form)    { find('#task_second')                        }
      let!(:tag1_check_box) { find("input[id='task_tag_ids_#{tag1.id}']") }
      let!(:tag2_check_box) { find("input[id='task_tag_ids_#{tag2.id}']") }

      context '正しい値を入力' do
        # 前提: task.tagsは tag1のみ
        it 'タスク情報を更新できる' do
          #フォーム送信
          title_form.set('タスク2')
          hour_form.set('02')
          minute_form.set('03')
          second_form.set('04')
          tag2_check_box.click
          click_on '更新する'
          sleep 0.1
          # ページ表示
          expect(page).to have_current_path routine_path(routine)
          expect(page).to have_selector     "#task_#{task.id}"
          
          task_field = find("#task_#{task.id}")
          expect(task_field).to     have_selector 'h1', text: 'タスク2'
          expect(task_field).not_to have_content  task.title
          expect(task_field).to     have_content  tag1.name
          expect(task_field).to     have_content  tag2.name
          expect(task_field).to     have_content  '02h'
          expect(task_field).to     have_content  '03m'
          expect(task_field).to     have_content  '04s'
          #DB
          task.reload
          expect(task.title).to                    eq      'タスク2'
          expect(task.estimated_time_in_second).to eq      (2*3600) + (3*60) + 4
          expect(task.tags).to                     include tag2
        end
      end

      context '不正な値を入力' do
        it 'タスク更新に失敗する' do
          # フォームに入力
          title_form.set('')
          tag2_check_box.click
          click_on '更新する'
          sleep 0.1
          # ページ表示
          expect(page).to have_current_path routine_path(routine)
          task_form  = find("#task-form-for-#{task.id}") #ページ更新後の要素を再取得
          title_form = find("#task_title")
          expect(task_form).to        have_content       'タイトルを入力してください'
          expect(title_form.value).to eq                 ''
          expect(task_form).to        have_checked_field "task_tag_ids_#{tag2.id}"
          # DB
          task.reload
          expect(task.title).not_to eq      ''
          expect(task.tags).not_to  include tag2
        end
      end
    end

    describe 'タスク削除処理' do
      it 'タスクを削除できる' do
        #削除前のDB
        task_size_prev = routine.tasks.size
        task_tags_prev = TaskTag.all.size
        # 削除ボタン
        click_on "task-delete-btn-#{task.id}"
        # ページ
        expect(page).to     have_current_path routine_path(routine)
        expect(page).to     have_content      "タスクを削除しました。(タスク名：#{task.title})"
        expect(page).not_to have_selector     "#task_#{task.id}"
        # DB
        expect(routine.tasks.size).to eq   task_size_prev - 1
        expect(TaskTag.all.size).to   be < task_tags_prev
      end
    end

    describe 'タスクの並べ替え処理' do
      let!(:task2) { create(:task, routine: routine, position: 2) }

      before do
        visit routine_path(routine)
      end

      it 'task1, task2の順番になっている' do
        expect(task.position).to be < task2.position
      end

      it 'タスク一覧がpositionカラムの昇順になっている' do
        # タスク一覧の要素を取得
        task_index   = find('#task-index')
        all_task_els = task_index.all('li')
        # タスクをposition順にDBから取得
        tasks_sorted = routine.tasks.order(position: :asc)

        all_task_els.each_with_index do |task_el, index|
          expected_id = "task_#{tasks_sorted[index].id}"
          actual_id   = task_el['id']
          expect(expected_id).to eq actual_id
        end
      end

      context '↑ボタン' do
        it 'positionを1つ上にできる' do
          # 変更前のDB
          task1_posi_prev = task.position
          task2_posi_prev = task2.position
          # task2の上ボタンを押す
          find("#move-higher-btn-#{task2.id}").click
          sleep 0.1
          # ページ
          expect(page).to have_current_path routine_path(routine)
          # DBの変化
          task.reload
          task2.reload
          expect(task2.position).to eq task1_posi_prev
          expect(task.position).to  eq task2_posi_prev
        end

        it '一番上の要素に対しては変化なし' do
          # 変更前のDB
          task1_posi_prev = task.position
          task2_posi_prev = task2.position
          # task1の上ボタンを押す
          find("#move-higher-btn-#{task.id}").click
          sleep 0.1
          # ページ
          expect(page).to have_current_path routine_path(routine)
          # DBの変化
          task.reload
          task2.reload
          expect(task.position).to  eq task1_posi_prev
          expect(task2.position).to eq task2_posi_prev
        end
      end

      context '↓ボタン' do
        it '順番を1つ下にできる' do
          # 変更前のDB
          task1_posi_prev = task.position
          task2_posi_prev = task2.position
          # task1の↓ボタンを押す
          find("#move-lower-btn-#{task.id}").click
          sleep 0.1
          # ページ
          expect(page).to have_current_path routine_path(routine)
          # DBの変化
          task.reload
          task2.reload
          expect(task.position).to  eq task2_posi_prev
          expect(task2.position).to eq task1_posi_prev
        end

        it '一番下の要素に対しては変化なし' do
          # 変更前のDB
          task1_posi_prev = task.position
          task2_posi_prev = task2.position
          # task1の上ボタンを押す
          find("#move-lower-btn-#{task2.id}").click
          sleep 0.1
          # ページ
          expect(page).to have_current_path routine_path(routine)
          # DBの変化
          task.reload
          task2.reload
          expect(task.position).to  eq task1_posi_prev
          expect(task2.position).to eq task2_posi_prev
        end
      end
    end
  end
end
