require 'rails_helper'

RSpec.describe "Rewards", type: :system, js: true do  
  context 'ログイン前' do
    it 'トップページに遷移' do
      login_failed_check(rewards_path)
    end
  end

  context 'ログイン後' do
    # 称号データを作成(画像は適当)
    before do
      image_obj = File.open(Rails.root.join('public', 'image_for_test.png'))

      Reward.create!(
        name:        "はじまりの一歩！",
        condition:   "completed_routine_1?",
        description: "ルーティンを1回クリアする",
        image:       image_obj
      )
    
      Reward.create!(
        name:        "小さな達成者",
        condition:   "completed_routines_3?",
        description: "ルーティンを3回クリアする",
        image:       image_obj
      )
    
      Reward.create!(
        name:        "若葉の成長",
        condition:   "get_experiences_10?",
        description: "経験値を10獲得する",
        image:       image_obj
      )
    
      Reward.create!(
        name:        "朝の森の案内人",
        condition:   "post_routine_1?",
        description: "ルーティンを1つ投稿する",
        image:       image_obj
      )
    end

    let!(:user)     { create(:user   , :for_system_spec                             ) }
    let!(:routine)  { create(:routine                  , user: user, is_active: true) }
    let!(:task)     { create(:task                     , routine: routine           ) }
    let!(:tag)      { create(:tag) }
    let!(:task_tag) { create(:task_tag                  , task: task, tag: tag      ) }
    let!(:rewards)  { Reward.all }

    # ログイン => rewardsページに遷移
    describe 'header/footerのテスト' do
      let!(:path) { rewards_path }
  
      context 'ログイン後' do
        it_behaves_like 'ログイン後Header/Footerテスト'
      end
    end
    
    before do
      login_as(user)
      visit rewards_path
    end

    it 'ページにアクセスできる' do
      expect(page).to have_current_path(rewards_path)
    end

    describe 'パンくず' do
      let!(:breadcrumb_container) { find('.breadcrumbs-container-custom') }

      it '正しく表示される' do
        expect(breadcrumb_container).to have_selector "a[href='#{my_pages_path}']"
        expect(breadcrumb_container).to have_content  '称号一覧'
      end

      it 'マイページに遷移できる' do
        breadcrumb_container.find("a[href='#{my_pages_path}']").click

        expect(page).to have_current_path my_pages_path
      end
    end

    context '称号獲得前' do
      it '各称号のdescriptionが表示される' do
        rewards.each{ |reward|
          expect(page).to     have_selector("#reward-description-#{reward.id}")
          expect(page).not_to have_selector("#reward-card-#{reward.id}")
        }
      end
    end

    describe '各称号の獲得後' do
      it 'はじまりの一歩！' do
        # 獲得条件をクリア
        user.update!(complete_routines_count: 1)
        sleep 0.5
        # マイページに遷移して称号を獲得
        visit my_pages_path
        expect(page).to have_content('新たな称号を獲得しました！')
        expect(user.rewards).to include(Reward.find_by(name: 'はじまりの一歩！'))
        # 称号一覧に遷移
        visit rewards_path
        expect(page).to have_selector('h2', text: 'はじまりの一歩！')
      end

      it '若葉の成長' do
        # 獲得条件をクリア
        UserTagExperience.create!(user_id: user.id, tag_id: tag.id, experience_point: 10)
        sleep 0.5
        # マイページに遷移して称号を獲得
        visit my_pages_path
        expect(page).to have_content('新たな称号を獲得しました！')
        expect(user.rewards).to include(Reward.find_by(name: '若葉の成長'))

        visit rewards_path
        expect(page).to have_selector('h2', text: '若葉の成長')
      end

      it '小さな達成者' do
        # 獲得条件をクリア
        user.update!(complete_routines_count: 3)
        sleep 0.5
        # マイページに遷移して称号を獲得
        visit my_pages_path
        expect(page).to have_content('新たな称号を獲得しました！')
        expect(user.rewards).to include(Reward.find_by(name: '小さな達成者'))

        visit rewards_path
        expect(page).to have_selector('h2', text: '小さな達成者')
      end

      it '朝の森の案内人' do
        # 獲得条件をクリア
        routine.update!(is_posted: true)
        sleep 0.5
        # マイページに遷移して称号を獲得
        visit my_pages_path
        expect(page).to have_content('新たな称号を獲得しました！')
        expect(user.rewards).to include(Reward.find_by(name: '朝の森の案内人'))

        visit rewards_path
        expect(page).to have_selector('h2', text: '朝の森の案内人')
      end
    end
  end
end
