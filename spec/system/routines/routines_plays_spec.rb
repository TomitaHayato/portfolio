require 'rails_helper'

RSpec.describe "Routines::Plays", type: :system, js: true do
  let!(:user)      { create(:user, :for_system_spec) }
  let!(:routine)   { create(:routine, user: user, is_active: true) }

  let!(:task1)     { create(:task, routine: routine, position: 1) }
  let!(:task2)     { create(:task, routine: routine, position: 2) }

  let!(:tag1)      { create(:tag) }
  let!(:tag2)      { create(:tag) }
  
  let!(:task_tag)  { create(:task_tag, task: task1, tag: tag1) }
  let!(:task_tag)  { create(:task_tag, task: task1, tag: tag2) }
  let!(:task_tag)  { create(:task_tag, task: task2, tag: tag2) }

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
    end
    
    it '正常にページが表示される' do
      expect(page).to have_current_path(play_path(routine))
      expect(page).to have_selector('h1', text: routine.title)
      expect(page).to have_selector('p',  text: task1.title)
      expect(page).not_to have_selector('p',  text: task2.title)
      expect(page).to have_selector('#countdown-zone')
    end

    it '「達成」を押すと次のタスクに遷移する' do
      click_on '達成'
      expect(page).to have_current_path(play_path(routine))
      expect(page).to have_selector('h1', text: routine.title)
      expect(page).not_to have_selector('p',  text: task1.title)
      expect(page).to have_selector('p',  text: task2.title)
      expect(page).to have_selector('#countdown-zone')
    end

    it '「達成」を押すと次のタスクに遷移する' do
      click_on 'スキップ'
      expect(page).to have_current_path(play_path(routine))
      expect(page).to have_selector('h1', text: routine.title)
      expect(page).not_to have_selector('p',  text: task1.title)
      expect(page).to have_selector('p',  text: task2.title)
      expect(page).to have_selector('#countdown-zone')
    end

    it '[x]でマイページに遷移できる' do
      click_on 'x'
      expect(page).to have_current_path(my_pages_path)
    end

    describe 'すべてのタスク完了後' do
      before do
        # タスクをすべて完了させる
        click_on 'スキップ'
        sleep 0.1
        click_on '達成'
        sleep 0.1
      end

      it 'ルーティン完了画面に遷移し、経験値が表示される' do
        expect(page).to have_current_path(routines_finishes_path)
        expect(page).to have_content('ルーティンを達成しました！')

        # 経験値の表示
        expect(page).not_to have_selector("#experience-#{tag1.name}")
        expect(page).to have_selector("#experience-#{tag2.name}")
      end

      it 'マイページに遷移できる' do
        click_on 'マイページへ'
        expect(page).to have_current_path(my_pages_path)
      end
    end
  end
end