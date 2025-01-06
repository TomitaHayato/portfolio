require 'rails_helper'

RSpec.describe "MyPages", type: :system, js:true do
  let!(:user)      { create(:user, :for_system_spec) }

  context 'ログイン前' do
    it 'トップページに遷移' do
      login_failed_check(my_pages_path)
    end
  end

  context 'ログイン後' do
    before do
      login_as(user)
      visit my_pages_path
    end

    describe 'Header/Footerのテスト' do
      it_behaves_like('ログイン後Header/Footerテスト')
    end

    it '正常に遷移できる' do
      visit my_pages_path

      expect(page).to have_current_path(my_pages_path)
      expect(page).to have_selector('#logged-in-header')
    end

    it '「おはようございます！〜さん」と表示される' do
      expect(page).to have_content("おはようございます！")
      expect(page).to have_content(user.name)
    end

    context '実践中のルーティンがない場合' do
      before do
        visit my_pages_path
      end

      it '「ルーティンを実践中にしましょう！！」リンクが表示' do
        expect(page).to have_content 'ルーティンを実践中にしましょう！！'
      end

      it 'リンクを押す=>ルーティン一覧に遷移' do
        click_on 'ルーティンを実践中にしましょう！！'
        expect(page).to have_current_path routines_path
      end
    end

    context '実践中のルーティンはあるが、taskがない場合' do
      let!(:routine)   { create(:routine, user: user, is_active: true) }

      before do
        visit my_pages_path
      end

      it 'ルーティン情報が表示される' do
        routine_field = find('#routine-field')
        # リンク
        expect(routine_field).to have_selector "a[href='#{routine_path(routine)}']"
        # routineの情報
        expect(routine_field).to have_content  routine.title
        expect(routine_field).to have_content  routine.start_time.strftime('%H:%M')
        expect(routine_field).to have_content  routine.completed_count
        expect(routine_field).to have_content  '00h'
        expect(routine_field).to have_content  '00m'
        expect(routine_field).to have_content  '00s'
        expect(routine_field).to have_selector '#notification-btn'
      end

      it 'タスクを追加しましょう！リンクが表示' do
        routine_field = find('#routine-field')
        expect(routine_field).to have_content             'タスクを追加しましょう！'
        expect(routine_field).to have_selector 'a', text: 'タスク追加画面へ'
      end

      it 'ルーティン詳細画面に遷移できる' do
        click_on 'タスク追加画面へ'
        expect(page).to have_current_path routine_path(routine)
      end
    end

    context '実践中のルーティンがあり、taskもある場合' do
      let!(:routine)   { create(:routine, user: user, is_active: true) }
      let!(:task1)     { create(:task, routine: routine) }
      let!(:task2)     { create(:task, routine: routine) }

      let!(:tag1)      { create(:tag, name: '勉強') }
      let!(:tag2)      { create(:tag, name: '運動') }

      before do
        # Tagをtaskに結びつける
        create(:task_tag, task: task1, tag: tag1)
        create(:task_tag, task: task2, tag: tag2)
        
        visit my_pages_path
      end

      describe 'ページ内容' do
        describe 'ルーティン表示部分' do
          it 'ルーティン情報が表示される' do
            expect(page).to have_selector('#routine-field')
            routine_field = find('#routine-field')
            # ルーティン情報
            expect(routine_field).to have_content(routine.title)
            expect(routine_field).to have_content(routine.start_time.strftime("%H:%M"))
            expect(routine_field).to have_content(routine.completed_count)
            # リンク
            expect(routine_field).to have_selector "a[href='#{routine_path(routine)}']"
            expect(routine_field).to have_selector '#notification-btn'
            expect(routine_field).to have_selector 'a'      , text: 'スタート'
            expect(routine_field).to have_selector 'summary', text: 'タスク一覧'
          end

          it 'タスク情報が表示される' do
            find("#tasks-display-btn-#{routine.id}").click
            #各taskの要素
            tasks_container = find('#tasks-container')
            expect(tasks_container).to have_selector "#task-field-#{task1.id}"
            expect(tasks_container).to have_selector "#task-field-#{task2.id}"

            task1_field = find("#task-field-#{task1.id}")
            task2_field = find("#task-field-#{task2.id}")
            # task1のタスク情報
            expect(task1_field).to have_content(task1.title)
            expect(task1_field).to have_content(tag1.name)
            expect(task1_field).to have_content('00 h')
            expect(task1_field).to have_content('01 m')
            expect(task1_field).to have_content('00 s')
            # task2のタスク情報
            expect(task2_field).to have_content(task2.title)
            expect(task2_field).to have_content(tag2.name)
            expect(task2_field).to have_content('00 h')
            expect(task2_field).to have_content('01 m')
            expect(task2_field).to have_content('00 s')
          end
        end

        describe 'ステータス表示' do
          let(:reward) { create(:reward, :hajimarinoippo) }

          before do
            # 経験値を取得させる
            create(:user_tag_experience, user: user, tag: tag2)                                       # 今       (tag2: 1 exp)
            create(:user_tag_experience, user: user, tag: tag1, created_at: (1.weeks.ago + 1.minute)) # 1週間以内 (tag1: 1 exp)
            create(:user_tag_experience, user: user, tag: tag1, created_at: (1.month.ago + 1.minute)) # 1ヶ月以内 (tag1: 1 exp)
            create(:user_tag_experience, user: user, tag: tag1, created_at: (1.month.ago - 1.minute)) # 1ヶ月以降 (tag1: 1 exp)
            
            visit my_pages_path
          end

          it 'ユーザーのステータスが表示される' do
            expect(page).to have_selector('#user-status')
            expect(page).to have_selector('#user-level-stat')
            expect(page).to have_selector('#exp-tablist')
          end

          let!(:user_status)     { find('#user-status') }
          let!(:user_level_stat) { find('#user-level-stat') }
          let!(:exp_tablist)     { find('#exp-tablist') }

          it 'statにユーザーのレベルが表示される' do
            expect(user_level_stat).to have_content user.level
            expect(user_level_stat).to have_content "次のレベルまであと #{user.exp_to_next_level} exp"
          end

          it '称号がある場合、statに表示される' do
            # 称号獲得 >> 称号をプロフに設定
            user.rewards << reward
            sleep 0.1
            reward.featuring_users << user
            sleep 0.1
            visit my_pages_path

            user_level_stat = find('#user-level-stat')
            expect(user_level_stat).to have_content reward.name
          end

          it '全期間の経験値が表示される' do
            exp_tablist.find('input[aria-label="全期間"]').click
            sleep 0.1

            expect(exp_tablist).to have_selector '#user-xp-total'        
            user_xp_total = find('#user-xp-total')
            
            expect(user_xp_total).to have_content  "Total: 4 exp"
            expect(user_xp_total).to have_selector 'td', text: tag1.name
            expect(user_xp_total).to have_selector 'td', text: tag2.name
            expect(user_xp_total).to have_selector 'td', text: '3'
            expect(user_xp_total).to have_selector 'td', text: '1'
            expect(user_xp_total).to have_selector 'td', text: '75.0 %'
            expect(user_xp_total).to have_selector 'td', text: '25.0 %'
          end

          it '1ヶ月の経験値が表示される' do
            exp_tablist.find('input[aria-label="1ヶ月"]').click
            sleep 0.1

            expect(exp_tablist).to have_selector '#user-xp-monthly'        
            user_xp_monthly = find('#user-xp-monthly')
            
            expect(user_xp_monthly).to have_content  "Total: 3 exp"
            expect(user_xp_monthly).to have_selector 'td', text: tag1.name
            expect(user_xp_monthly).to have_selector 'td', text: tag2.name
            expect(user_xp_monthly).to have_selector 'td', text: '2'
            expect(user_xp_monthly).to have_selector 'td', text: '1'
            expect(user_xp_monthly).to have_selector 'td', text: '66.7 %'
            expect(user_xp_monthly).to have_selector 'td', text: '33.3 %'
          end

          it '1週間の経験値が表示される' do
            exp_tablist.find('input[aria-label="1週間"]').click
            sleep 0.1

            expect(exp_tablist).to have_selector '#user-xp-weekly'        
            user_xp_weekly = find('#user-xp-weekly')
            
            expect(user_xp_weekly).to have_content  "Total: 2 exp"
            expect(user_xp_weekly).to have_selector 'td', text: tag1.name
            expect(user_xp_weekly).to have_selector 'td', text: tag2.name
            expect(user_xp_weekly).to have_selector 'td', text: '1'
            expect(user_xp_weekly).to have_selector 'td', text: '1'
            expect(user_xp_weekly).to have_selector 'td', text: '50.0 %'
            expect(user_xp_weekly).to have_selector 'td', text: '50.0 %'
          end        
        end
      end

      describe 'メインコンテンツからのページ遷移' do
        it 'ルーティン詳細ページに遷移' do
          btn = find("a[href='#{routine_path(routine)}']", text: '編集')
          btn.click
          expect(page).to have_current_path(routine_path(routine))
        end
        
        it 'タスク遂行画面に遷移' do
          btn = find('a', text: 'スタート')
          btn.click
          expect(page).to have_current_path(play_path(routine))
        end
      end

      describe '通知設定を変更できる' do
        let!(:routine_field) { find('#routine-field') }

        it '通知設定をメールに変更できる' do
          find('#notification-btn button').click
          sleep 0.1
          user.reload
          expect(user.notification).to eq 'email'
        end

        it '通知設定をオフにできる' do
          #通知設定をメールにする
          user.notification = 'email'
          user.save!
          sleep 0.1
          
          visit my_pages_path
          # ボタンを押す
          find('#notification-btn button').click
          sleep 0.1
          user.reload
          expect(user.notification).to eq 'off'
        end
      end
    end
  end
end
