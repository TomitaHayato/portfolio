require 'rails_helper'

RSpec.describe "Routines::Plays", type: :system, js: true do
  let!(:user)      { create(:user, :for_system_spec) }
  let!(:routine)   { create(:routine, user: user, is_active: true) }

  let!(:task1)     { create(:task, routine: routine, position: 1) }
  let!(:task2)     { create(:task, routine: routine, position: 2) }

  let!(:tag1)      { create(:tag) }
  let!(:tag2)      { create(:tag) }

  before do
    create(:task_tag, task: task1, tag: tag1)
    create(:task_tag, task: task1, tag: tag2)
    create(:task_tag, task: task2, tag: tag2)
  end

  describe 'ログイン前' do
    it 'ログインページに遷移' do
      login_failed_check(play_path(routine))
    end
  end

  describe 'ログイン後' do
    it 'play_pathへのPOSTメソッドを介さないとページに遷移できない' do
      login_as(user)
      visit play_path(routine)
      
      expect(page).to have_current_path(my_pages_path)
      expect(page).to have_content('ページに遷移できませんでした')
    end
    
    before do
      login_as(user)
      click_on 'スタート'
      sleep 0.1 # 画面遷移するまでのラグ
    end

    it 'アクセスできる' do
      expect(page).to have_current_path(play_path(routine))
    end

    describe 'Header/Footerのテスト' do
      it_behaves_like('ログイン後Header/Footerテスト')
    end

    it '正常にページが表示される' do
      main_container = find('#routine-plays-view')
      expect(main_container).to     have_selector 'h1',  text: task1.title
      expect(main_container).not_to have_selector 'h1',  text: task2.title
      expect(main_container).to     have_selector '#countdown-field'
      expect(main_container).to     have_selector 'a',  text: '達成'
      expect(main_container).to     have_selector 'p',  text: tag1.name
      expect(main_container).to     have_selector 'p',  text: tag2.name
      expect(main_container).to     have_selector 'a',  text: 'スキップ'
    end

    it '「達成」を押すと次のタスクに遷移する' do
      click_on '達成'
      sleep 0.1
      expect(page).to have_current_path(play_path(routine))
      main_container = find('#routine-plays-view')
      expect(main_container).not_to have_selector 'h1',  text: task1.title
      expect(main_container).to     have_selector 'h1',  text: task2.title
      expect(main_container).to     have_selector 'a',   text: '達成'
      expect(main_container).to     have_selector 'a',   text: 'スキップ'
      expect(main_container).to     have_selector '#countdown-field'
    end

    it '「達成」を押すと次のタスクに遷移する' do
      click_on 'スキップ'
      sleep 0.1
      expect(page).to have_current_path(play_path(routine))
      main_container = find('#routine-plays-view')
      expect(main_container).not_to have_selector 'h1',  text: task1.title
      expect(main_container).to     have_selector 'h1',  text: task2.title
      expect(main_container).to     have_selector 'a',   text: '達成'
      expect(main_container).to     have_selector 'a',   text: 'スキップ'
      expect(main_container).to     have_selector '#countdown-field'
    end

    it '[x]でマイページに遷移できる' do
      click_on '×'
      expect(page).to have_current_path(my_pages_path)
    end

    it 'カウントダウンしている' do
      time_prev = find('#countdown-display p').text
      sleep 1
      time_now  = find('#countdown-display p').text
      expect(time_prev).not_to eq time_now
    end

    describe 'すべてのタスク完了後' do
      before do
        # タスクをすべて完了させる
        click_on 'スキップ'
        sleep 0.1
        click_on '達成'
        sleep 0.1
      end

      it 'routine_finishes_pathに遷移' do
        expect(page).to have_current_path(routine_finishes_path)
      end

      describe 'Header/Footerのテスト' do
        it_behaves_like('ログイン後Header/Footerテスト')
      end

      it 'ルーティン完了画面に遷移し、経験値が表示される' do
        expect(page).to     have_content  'ルーティンを達成しました！'
        # 獲得経験値の表示
        expect(page).not_to have_selector "#experience-#{tag1.name}"
        expect(page).to     have_selector "#experience-#{tag2.name}"
      end

      it 'マイページに遷移できる' do
        click_on 'マイページへ'
        expect(page).to have_current_path(my_pages_path)
      end
    end
  end
end
