require 'rails_helper'

RSpec.describe "Rewards", type: :system, js: true do
  context 'ログイン前' do
    it 'トップページに遷移' do
      login_failed_check(rewards_path)
    end
  end

  context 'ログイン後' do
    before do
      Reward.create!(
        name: "はじまりの一歩！",
        condition: "completed_routine_1?",
        description: "ルーティンを1回クリアする"
      )
    
      Reward.create!(
        name: "小さな達成者",
        condition: "completed_routines_3?",
        description: "ルーティンを3回クリアする"
      )
    
      Reward.create!(
        name: "若葉の成長",
        condition: "get_experiences_10?",
        description: "経験値を10獲得する"
      )
    
      Reward.create!(
        name: "朝の森の案内人",
        condition: "post_routine_1?",
        description: "ルーティンを1つ投稿する"
      )
    end

    let!(:user)     { create(:user, :for_system_spec) }
    let!(:routine)  { create(:routine, user: user, is_active: true) }
    let!(:task)     { create(:task, routine: routine) }
    let!(:tag)      { create(:tag) }
    let!(:task_tag) { create(:task_tag, task: task, tag: tag) }
    let!(:rewards)  { Reward.all }

    before do
      login_as(user)
      visit rewards_path
    end

    it 'ページが正しく表示される' do
      expect(page).to have_current_path(rewards_path)
      rewards.each do |reward|
        expect(page).to have_selector("#reward-description-#{reward.id}")
      end
    end

    describe '各称号の獲得処理' do
      it 'はじまりの一歩！' do
        user.update!(complete_routines_count: 1)
        sleep 0.5
        p rewards.size

        visit my_pages_path
        expect(page).to have_content('新たな称号を獲得しました！')

        visit rewards_path
        expect(page).to have_selector('h2', text: 'はじまりの一歩！')
      end

      it '若葉の成長' do
        UserTagExperience.create!(user_id: user.id, tag_id: tag.id, experience_point: 10)
        sleep 0.5

        visit my_pages_path
        expect(page).to have_content('新たな称号を獲得しました！')

        visit rewards_path
        expect(page).to have_selector('h2', text: '若葉の成長')
      end

      it '小さな達成者' do
        user.update!(complete_routines_count: 3)
        sleep 0.5

        visit my_pages_path
        expect(page).to have_content('新たな称号を獲得しました！')

        visit rewards_path
        expect(page).to have_selector('h2', text: '小さな達成者')
      end

      it '朝の森の案内人' do
        routine.update!(is_posted: true)
        sleep 0.5

        visit my_pages_path
        expect(page).to have_content('新たな称号を獲得しました！')

        visit rewards_path
        expect(page).to have_selector('h2', text: '朝の森の案内人')
      end
    end
  end
end
