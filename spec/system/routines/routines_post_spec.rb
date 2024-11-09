require 'rails_helper'

RSpec.describe "Routines::PostPaths", type: :system, js: true do
  describe 'ログイン前' do
    it 'ログインページに遷移' do
      login_failed_check(routines_posts_path)
    end
  end

  describe 'ログイン後' do
    let!(:user)      { create(:user, :for_system_spec) }
    let!(:routine)   { create(:routine, user: user, is_posted: true, title: 'ルーティンA') }
    let!(:routine2)  { create(:routine, user: user) }
    let!(:task)      { create(:task, routine: routine) }
    let!(:tag)       { create(:tag) }
    let!(:task_tag)  { create(:task_tag, task: task, tag: tag) }
  
    let!(:userB)     { create(:user, :for_system_spec) }
    let!(:routineB)  { create(:routine, user: userB, is_posted: true, title: 'ルーティンB') }
    let!(:taskB)     { create(:task, routine: routineB) }
    let!(:tagB)      { create(:tag) }
    let!(:task_tagB) { create(:task_tag, task: taskB, tag: tagB) }

    before do
      login_as(user)
      visit routines_posts_path
    end

    it 'アクセスできる' do
      expect(page).to     have_current_path routines_posts_path
    end

    describe 'Header/Footerのテスト' do
      it_behaves_like('ログイン後Header/Footerテスト')
    end

    it '正常にページが表示される' do
      expect(page).to     have_selector     '#user_words'
      expect(page).to     have_selector     'h1', text: routine.title
      expect(page).not_to have_selector     'h1', text: routine2.title
      expect(page).to     have_selector     'h1', text: routineB.title

      find("#tasks-display-btn-#{routine.id}").click
      expect(page).to have_content task.title
      expect(page).to have_content tag.name
    end

    describe '投稿処理のテスト' do
      it '投稿できる' do
        click_on "routine-post-btn-#{routine2.id}"
        expect(page).to have_content('ルーティンを投稿しました')

        visit routines_posts_path
        expect(page).to have_selector('h1', text: routine2.title)
      end

      it '非公開にできる' do
        click_on "routine-unpost-btn-#{routine.id}"
        expect(page).to have_content('ルーティンを非公開にしました')

        visit routines_posts_path
        expect(page).not_to have_selector('h1', text: routine.title)
      end
    end

    describe 'コピー機能のテスト' do
      it 'コピーできる' do
        click_on "copy-btn-#{routineB.id}"
        expect(page).to have_content("コピーしました。（#{routineB.title}")
        
        visit routines_path
        expect(page).to have_selector('h1', text: routineB.title)

        expect(page).not_to have_selector("#task-display-btn-#{routineB.id}")
        expect(page).to have_selector('h1', text: taskB.title, visible: false)
        expect(page).to have_selector('p', text: tagB.name,   visible: false)
      end
    end

    describe '検索機能のテスト' do
      before do
        visit routines_posts_path
      end

      let!(:search_form) { find('#user_words') }

      it 'タイトル/説明文で検索できる' do
        search_form.set('ルーティンB')
        click_on '検索'
        expect(page).not_to have_selector("#posted-routine-#{routine.id}")
        expect(page).to have_selector("#posted-routine-#{routineB.id}")
        expect(search_form.value).to eq 'ルーティンB'

        search_form.set(routine.description)
        click_on '検索'
        expect(page).to have_selector("#posted-routine-#{routine.id}")
        expect(page).not_to have_selector("#posted-routine-#{routineB.id}")
        expect(search_form.value).to eq routine.description
      end

      it '絞り込みできる' do
        select '自分の投稿', from: 'filter_target'
        click_on '検索'
        expect(page).to have_selector("#posted-routine-#{routine.id}")
        expect(page).not_to have_selector("#posted-routine-#{routineB.id}")

        sleep 0.1
        select 'ユーザーの投稿', from: 'filter_target'
        click_on '検索'
        expect(page).to have_selector("#posted-routine-#{routine.id}")
        expect(page).to have_selector("#posted-routine-#{routineB.id}")
      end
    end

    describe 'お気に入り機能のテスト' do
      it 'お気に入り登録できる' do
        click_on "like-btn-off-#{routine.id}"
        sleep 0.1

        expect(page).to have_selector("#like-btn-on-#{routine.id}")
        expect(page).not_to have_selector("#like-btn-off-#{routine.id}")

        select 'お気に入り', from: 'filter_target'
        click_on '検索'
        expect(page).to have_selector("#posted-routine-#{routine.id}")
        expect(page).not_to have_selector("#posted-routine-#{routineB.id}")

        expect(user.liked_routines).to include(routine)
      end
    end
  end
end
