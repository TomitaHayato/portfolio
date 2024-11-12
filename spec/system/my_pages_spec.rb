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
      expect(page).to have_content("#{user.name}さん")
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

    context '実践中のルーティンにtaskがない場合' do
      let!(:routine)   { create(:routine, user: user, is_active: true) }

      before do
        visit my_pages_path
      end

      it 'ルーティン情報が表示される' do
        routine_field = find('#routine-field')
        # リンク
        expect(routine_field).to have_selector "a[href='#{edit_routine_path(routine)}']"
        expect(routine_field).to have_selector "a[href='#{routine_path(routine)     }']"
        # routineの情報
        expect(routine_field).to have_content routine.title
        expect(routine_field).to have_content routine.start_time.strftime('%H:%M')
        expect(routine_field).to have_content routine.completed_count
        expect(routine_field).to have_content '00h'
        expect(routine_field).to have_content '00m'
        expect(routine_field).to have_content '00s'
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

    context '実践中のルーティンがある場合' do
      let!(:routine)   { create(:routine, user: user, is_active: true) }
      let!(:task1)     { create(:task, routine: routine) }
      let!(:task2)     { create(:task, routine: routine) }

      let!(:tag1)      { create(:tag, name: '勉強') }
      let!(:tag2)      { create(:tag, name: '運動') }

      before do
        # Tagをtaskに結びつける
        create(:task_tag, task: task1, tag: tag1)
        create(:task_tag, task: task2, tag: tag2)

        # 経験値を取得させる（取得したタイミングを分ける）
        create(:user_tag_experience, user: user, tag: tag2)                                      # 今
        create(:user_tag_experience, user: user, tag: tag1, created_at: (1.weeks.ago + 1.minute))# 1週間以内
        create(:user_tag_experience, user: user, tag: tag1, created_at: (1.month.ago + 1.minute))# 1ヶ月以内
        create(:user_tag_experience, user: user, tag: tag1, created_at: (1.month.ago - 1.minute))# 1ヶ月以降
        
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
            expect(routine_field).to have_selector "a[href='#{edit_routine_path(routine)}']"
            expect(routine_field).to have_selector "a[href='#{routine_path(routine)     }']"
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

        describe '経験値表示' do
          it 'ユーザーの経験値が表示される' do
            expect(page).to have_content('獲得した経験値')
            expect(page).to have_selector('#user-xp-total')
            expect(page).to have_selector('#user-xp-monthly')
            expect(page).to have_selector('#user-xp-weekly')
          end

          it '経験値が各期間ごとに表示される' do
            # 獲得経験値は以下の通り
            # tag1: 1週間前、1ヶ月前、1ヶ月以上前にそれぞれ「1」ずつ
            # tag2: 直近1週間で「1」
            total_xp_zone   = find('#user-xp-total')
            monthly_xp_zone = find('#user-xp-monthly')
            weekly_xp_zone  = find('#user-xp-weekly')

            # 全期間
            expect(total_xp_zone).to   have_selector("#tag-total-xp-#{tag1.name} span",   text: tag1.name)
            expect(total_xp_zone).to   have_selector("#tag-total-xp-#{tag1.name} span",   text: "3")
            
            expect(total_xp_zone).to   have_selector("#tag-total-xp-#{tag2.name} span",   text: tag2.name)
            expect(total_xp_zone).to   have_selector("#tag-total-xp-#{tag2.name} span",   text: "1")

            # 1ヶ月間
            expect(monthly_xp_zone).to have_selector("#tag-monthly-xp-#{tag1.name} span", text: tag1.name)
            expect(monthly_xp_zone).to have_selector("#tag-monthly-xp-#{tag1.name} span", text: "2")
          
            expect(monthly_xp_zone).to have_selector("#tag-monthly-xp-#{tag2.name} span", text: tag2.name)
            expect(monthly_xp_zone).to have_selector("#tag-monthly-xp-#{tag2.name} span", text: "1")
            
            # 1週間
            expect(weekly_xp_zone).to  have_selector("#tag-weekly-xp-#{tag1.name} span",  text: tag1.name)
            expect(weekly_xp_zone).to  have_selector("#tag-weekly-xp-#{tag1.name} span",  text: "1")

            expect(weekly_xp_zone).to  have_selector("#tag-weekly-xp-#{tag2.name} span",  text: tag2.name)
            expect(weekly_xp_zone).to  have_selector("#tag-weekly-xp-#{tag2.name} span",  text: "1")
          end          
        end
      end

      describe 'メインコンテンツからのページ遷移' do
        it 'ルーティン編集ページに遷移' do
          btn = find('a', text: '編集')
          btn.click
          expect(page).to have_current_path(edit_routine_path(routine))
        end

        it 'ルーティン詳細ページに遷移' do
          btn = find('a', text: '詳細')
          btn.click
          expect(page).to have_current_path(routine_path(routine))
        end
        
        it 'タスク遂行画面に遷移' do
          btn = find('a', text: 'スタート')
          btn.click
          expect(page).to have_current_path(play_path(routine))
        end
      end
    end
  end
end
