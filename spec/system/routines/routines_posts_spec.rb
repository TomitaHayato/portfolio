require 'rails_helper'

RSpec.describe "Routines::PostPaths", type: :system, js: true do
  describe 'ログイン前' do
    it 'ログインページに遷移' do
      login_failed_check(routines_posts_path)
    end
  end

  describe 'ログイン後' do
    # ログインユーザーのデータ
    let!(:user)      { create(:user, :for_system_spec)                                   }
    let!(:routine)   { create(:routine, user: user, is_posted: true, title: 'ルーティンA') }
    let!(:routine2)  { create(:routine, user: user)                                      }
    let!(:task)      { create(:task, routine: routine)                                   }
    let!(:tag)       { create(:tag)                                                      }
    let!(:task_tag)  { create(:task_tag, task: task, tag: tag)                           }
    # 他のユーザーのデータ
    let!(:userB)     { create(:user, :for_system_spec)                                   }
    let!(:routineB)  { create(:routine, user: userB, is_posted: true, title: 'ルーティンB') }
    let!(:taskB)     { create(:task, routine: routineB)                                  }
    let!(:tagB)      { create(:tag)                                                      }
    let!(:task_tagB) { create(:task_tag, task: taskB, tag: tagB)                         }

    before do
      login_as(user)
      visit routines_posts_path
    end

    it 'アクセスできる' do
      expect(page).to have_current_path(routines_posts_path)
    end

    describe 'Header/Footerのテスト' do
      it_behaves_like('ログイン後Header/Footerテスト')
    end

    describe 'パンくず' do
      let!(:breadcrumb_container) { find('.breadcrumbs-container-custom') }

      it '正しく表示される' do
        expect(breadcrumb_container).to have_selector "a[href='#{my_pages_path}']"
        expect(breadcrumb_container).to have_content  '投稿一覧'
      end

      it 'マイページに遷移できる' do
        breadcrumb_container.find("a[href='#{my_pages_path}']").click
        expect(page).to have_current_path my_pages_path
      end
    end

    it '検索フォームが表示される' do
      saerch_container = find('#search-container')
      expect(saerch_container).to have_selector('#user_words')
      expect(saerch_container).to have_selector('#search-btn')
      expect(saerch_container).to have_selector('#column')
      expect(saerch_container).to have_selector('#direction')
      expect(saerch_container).to have_selector('#filter_target')
    end

    it '正常にページが表示される' do
      # 投稿されたルーティン
      [routine, routineB].each do |posted_routine|
        expect(page).to have_selector "#posted-routine-#{posted_routine.id}"
        routine_el =             find "#posted-routine-#{posted_routine.id}"
        expect(routine_el).to have_content posted_routine.user.name
        expect(routine_el).to have_content posted_routine.title
        expect(routine_el).to have_content posted_routine.description
        expect(routine_el).to have_content posted_routine.start_time.strftime('%H:%M')
      end
      # 未投稿のルーティン
      expect(page).not_to have_selector "#posted-routine-#{routine2.id}"
      # タスク情報
      routine_el = find "#posted-routine-#{routine.id}"
      routine_el.find("#tasks-display-btn-#{routine.id}").click
      expect(page).to have_content task.title
      expect(page).to have_content tag.name
    end

    describe '投稿処理のテスト' do
      before do
        visit routines_path
        @flash = find('#flash')
      end

      it '投稿できる' do
        # routine2を投稿する
        click_on "post-btn-#{routine2.id}"
        expect(@flash).to have_content('ルーティンを投稿しました')
        # 投稿一覧の表示
        visit routines_posts_path
        expect(page).to have_selector "#posted-routine-#{routine2.id}"
      end

      it '非公開にできる' do
        # routineを未投稿にする
        click_on "unpost-btn-#{routine.id}"
        expect(@flash).to have_content('ルーティンを非公開にしました')
        # 投稿一覧の表示
        visit routines_posts_path
        expect(page).not_to have_selector('h1', text: routine.title)
      end
    end

    describe 'コピー機能のテスト' do
      it 'コピーできる' do
        # コピー前のDB
        routines_size_prev = user.routines.size
        # コピー処理
        click_on "copy-btn-#{routineB.id}"
        sleep 0.1
        expect(find('#flash')).to have_content("コピーしました。（#{routineB.title}")
        #DB
        # Routines
        routines_size_now  = user.routines.size
        expect(routines_size_now).to eq routines_size_prev + 1
        routine_copied = user.routines.last
        # Tasks, Tags
        routine_copied.tasks.each_with_index do |task, index|
          #タスク情報がコピーできているか
          task_origin = routineB.tasks[index]
          task_copied = routine_copied.tasks[index]
          expect(task_copied.title).to                    eq task_origin.title
          expect(task_copied.estimated_time_in_second).to eq task_origin.estimated_time_in_second
          expect(task_copied.id).not_to                   eq task_origin.id
          #タグ情報がコピーできているか(タグの数で判定)
          expect(task_copied.tags.size).to                eq task_origin.tags.size
        end
        #Myルーティンページ
        # ルーティン情報
        visit routines_path
        expect(page).not_to   have_selector "#routine-#{routineB.id}"
        expect(page).to       have_selector "#routine-#{routine_copied.id}"
        routine_el =                   find "#routine-#{routine_copied.id}"
        expect(routine_el).to have_selector 'h1', text: routineB.title
        # タスク、タグ
        expect(page).not_to have_selector "#task-display-btn-#{routineB.id}"
        expect(page).to     have_selector 'h1', text: taskB.title, visible: false
        expect(page).to     have_selector 'p' , text: tagB.name,   visible: false
      end
    end

    describe '検索機能のテスト' do

      let!(:search_form) { find('#user_words') }

      it 'タイトル/説明文で検索できる' do
        search_form.set('ルーティンB')
        click_on '検索'
        expect(page).not_to          have_selector "#posted-routine-#{routine.id}"
        expect(page).to              have_selector "#posted-routine-#{routineB.id}"
        expect(search_form.value).to eq            'ルーティンB'

        search_form.set(routine.description)
        click_on '検索'
        expect(page).to              have_selector "#posted-routine-#{routine.id}"
        expect(page).not_to          have_selector "#posted-routine-#{routineB.id}"
        expect(search_form.value).to eq            routine.description
      end

      it '絞り込みできる' do
        select '自分の投稿', from: 'filter_target'
        click_on '検索'
        expect(page).to     have_selector "#posted-routine-#{routine.id}"
        expect(page).not_to have_selector "#posted-routine-#{routineB.id}"
        sleep 0.1

        select 'ユーザーの投稿', from: 'filter_target'
        click_on '検索'
        expect(page).to     have_selector "#posted-routine-#{routine.id}"
        expect(page).to     have_selector "#posted-routine-#{routineB.id}"
      end
    end

    describe 'お気に入り機能のテスト' do
      it 'お気に入り登録できる' do
        click_on "like-btn-off-#{routine.id}"
        sleep 0.1

        expect(page).to     have_selector "#like-btn-on-#{routine.id}"
        expect(page).not_to have_selector "#like-btn-off-#{routine.id}"

        select 'お気に入り', from: 'filter_target'
        click_on '検索'
        expect(page).to     have_selector "#posted-routine-#{routine.id}"
        expect(page).not_to have_selector "#posted-routine-#{routineB.id}"

        expect(user.liked_routines).to include(routine)
      end
    end
  end
end
