require 'rails_helper'

RSpec.describe "Routines#index", type: :system, js: true do
  let!(:user)           { create(:user, :for_system_spec) }
  let!(:user_other)     { create(:user, :for_system_spec) }
  let!(:routine)        { create(:routine, user: user, title: 'ルーティン1') }
  let!(:routine2)       { create(:routine, user: user, title: 'ルーティン2') }
  let!(:routine3)       { create(:routine, user: user_other) }
  let!(:task)           { create(:task, routine: routine) }
  let!(:tag)            { create(:tag) }
  let!(:task_tag)       { create(:task_tag, task: task, tag: tag) }

  context 'ログイン前' do
    it 'トップページに遷移' do
      login_failed_check(routines_path)
    end
  end

  context 'ログイン後' do
    before do
      login_as(user)
      visit routines_path
    end

    it 'ページが正しく表示される' do
      expect(page).to have_current_path(routines_path)
      expect(page).to have_selector('#user_words')
      expect(page).to have_selector('h1', text: routine.title)
      expect(page).to have_selector('h1', text: routine2.title)
      expect(page).not_to have_selector('h1', text: routine3.title)

      find("#tasks-display-btn-#{routine.id}").click
      expect(page).to have_content(task.title)
      expect(page).to have_content(tag.name)
    end

    it 'ルーティン作成画面に遷移できる' do
      find("a[href='#{new_routine_path}']").click
      expect(page).to have_current_path(new_routine_path)
    end

    it 'ルーティン編集画面に遷移できる' do
      click_on "edit-routine-btn-#{routine.id}"
      expect(page).to have_current_path(edit_routine_path(routine))
    end

    it 'ルーティン詳細画面に遷移できる' do
      click_on "show-routine-btn-#{routine.id}"
      expect(page).to have_current_path(routine_path(routine))
    end

    it 'ルーティンを削除できる' do
      page.accept_confirm("#{routine.title}を削除してもよろしいですか？") do
        click_on "delete-routine-btn-#{routine.id}"
      end
      expect(page).to have_current_path(routines_path)
      expect(page).to have_content("#{routine.title}を削除しました")
      expect(page).not_to have_selector("#routine-#{routine.id}")
    end

    it 'ルーティンを投稿できる' do
      # 「投稿する」を押すと投稿中になる
      click_on "routine-post-btn-#{routine.id}"
      expect(page).to have_current_path(routines_path)
      expect(page).to have_content('ルーティンを投稿しました')
      expect(page).to have_selector("#routine-unpost-btn-#{routine.id}")
      # 「投稿済み」を押すと、非公開になる
      click_on "routine-unpost-btn-#{routine.id}"
      expect(page).to have_current_path(routines_path)
      expect(page).to have_content('ルーティンを非公開にしました')
      expect(page).to have_selector("#routine-post-btn-#{routine.id}")
    end

    it 'ルーティンを実践中にできる' do
      # 「実践中」を押すと、ルーティンを実践中にできる
      click_on "active-btn-#{routine2.id}"
      expect(page).to have_current_path(routines_path)
      expect(page).to have_selector("#active-now-#{routine2.id}")
      # ルーティンを実践すると、他のルーティンは非アクティブになる
      click_on "active-btn-#{routine.id}"
      expect(page).to have_current_path(routines_path)
      expect(page).to have_selector("#active-now-#{routine.id}")
      expect(page).not_to have_selector("#active-now-#{routine2.id}")
    end

    describe 'ルーティン検索機能' do
      let!(:search_form) { find('#user_words') }

      it 'ルーティンのタイトル or 説明文で検索できる' do
        search_form.set('ルーティン2')
        click_on '検索'
        expect(page).to have_selector("#routine-index-page")
        expect(page).not_to have_selector("#routine-#{routine.id}")
        expect(page).to have_selector("#routine-#{routine2.id}")
        expect(search_form.value).to eq 'ルーティン2'

        search_form.set(routine.description)
        click_on '検索'
        expect(page).to have_selector("#routine-index-page")
        expect(page).to have_selector("#routine-#{routine.id}")
        expect(page).not_to have_selector("#routine-#{routine2.id}")
        expect(search_form.value).to eq routine.description
      end

      describe 'ルーティンを絞り込める' do
        before do
          click_on "routine-post-btn-#{routine.id}"
        end

        it '投稿済み' do
          select '投稿済み', from: 'filter_target'
          click_on '検索'
          expect(page).to have_selector("#routine-index-page")
          expect(page).to have_selector("#routine-#{routine.id}")
          expect(page).not_to have_selector("#routine-#{routine2.id}")
        end
        
        it '未投稿のみ' do
          select '未投稿', from: 'filter_target'
          click_on '検索'
          expect(page).to have_selector("#routine-index-page")
          expect(page).not_to have_selector("#routine-#{routine.id}")
          expect(page).to have_selector("#routine-#{routine2.id}")
        end

        it 'すべて' do
          select '投稿済み', from: 'filter_target'
          click_on '検索'
          sleep 0.1

          select 'すべて', from: 'filter_target'
          click_on '検索'
          expect(page).to have_selector("#routine-index-page")
          expect(page).to have_selector("#routine-#{routine.id}")
          expect(page).to have_selector("#routine-#{routine2.id}")
        end

        it '検索と絞り込みを同時に適用できる' do
          search_form = find('#user_words')
          search_form.set('ルーティン2')
          select '投稿済み', from: 'filter_target'
          click_on '検索'
          expect(page).to have_selector("#routine-index-page")
          expect(page).not_to have_selector("#routine-#{routine.id}")
          expect(page).not_to have_selector("#routine-#{routine2.id}")
          select 'すべて', from: 'filter_target'
          click_on '検索'
          expect(page).to have_selector("#routine-index-page")
          expect(page).not_to have_selector("#routine-#{routine.id}")
          expect(page).to have_selector("#routine-#{routine2.id}")
        end
      end

      it '検索のオートコンプリート機能を使える' do
        p '表示されるかどうか'
        search_form.set('ル')
        option1 = find('#search-options p', text: "ルーティン1")
        option2 = find('#search-options p', text: "ルーティン2")
        expect(option1).to be_visible
        expect(option2).to be_visible
        p 'クリックして検索フォームに入力できるかどうか'
        option1.click
        expect(search_form.value).to eq 'ルーティン1'
      end
    end
  end
end
