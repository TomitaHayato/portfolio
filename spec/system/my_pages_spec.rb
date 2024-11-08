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
    end

    describe 'Header/Footerのテスト' do
      let!(:path) { my_pages_path }

      it_behaves_like('ログイン後Header/Footerテスト')
    end

    context '実践中のルーティンがない場合' do
      before do
        visit my_pages_path
      end

      it '正常に遷移できる' do
        expect(page).to have_current_path(my_pages_path)
        expect(page).to have_selector('#logged-in-header')
      end

      it '「ルーティンを実践中にしましょう！！」と表示' do
        expect(page).to have_content('ルーティンを実践中にしましょう！！')
      end

      it 'ルーティン一覧に遷移' do
        click_on 'ルーティンを実践中にしましょう！！'
      end
    end

    context '実践中のルーティンにtaskがない場合' do
      let!(:routine)   { create(:routine, user: user, is_active: true) }

      before do
        visit my_pages_path
      end

      it 'タスクを追加しましょう！と表示される' do
        expect(page).to have_content('タスクを追加しましょう！')
        expect(page).to have_selector('a', text: 'タスク追加画面へ')
      end

      it 'ルーティン詳細画面に遷移できる' do
        click_on 'タスク追加画面へ'
        expect(page).to have_current_path(routine_path(routine))
      end
    end

    context '実践中のルーティンがある場合' do
      let!(:routine)   { create(:routine, user: user, is_active: true) }
      let!(:task1)     { create(:task, routine: routine) }
      let!(:task2)     { create(:task, routine: routine) }

      let!(:tag1)      { create(:tag, name: '勉強') }
      let!(:tag2)      { create(:tag, name: '運動') }

      before do
        create(:task_tag, task: task1, tag: tag1)
        create(:task_tag, task: task2, tag: tag2)

        create(:user_tag_experience, user: user, tag: tag2)
        create(:user_tag_experience, user: user, tag: tag1, created_at: (1.weeks.ago + 1.minute))

        create(:user_tag_experience, user: user, tag: tag1, created_at: (1.month.ago + 1.minute))
        create(:user_tag_experience, user: user, tag: tag1, created_at: (1.month.ago - 1.minute))
        
        visit my_pages_path
      end

      it '正常に遷移できる' do
        expect(page).to have_current_path(my_pages_path)
        expect(page).to have_selector('#logged-in-header')
      end

      it 'root_pathでマイページに遷移する' do
        visit root_path
        expect(page).to have_current_path(my_pages_path)
      end

      describe 'ページ内容' do
        it '「おはようございます！〜さん」と表示される' do
          expect(page).to have_content("おはようございます！")
          expect(page).to have_content("#{user.name}さん")
        end

        context '実践中のルーティンがある場合' do
          it 'ルーティン情報が表示される' do
            expect(page).to have_selector('#routine-field')

            expect(page).to have_content(routine.title)
            expect(page).to have_content(routine.start_time.strftime("%H:%M"))
            expect(page).to have_content(routine.completed_count)

            expect(page).to have_selector('a'      , text: 'スタート')
            expect(page).to have_selector('summary', text: 'タスク一覧')
          end

          it 'タスク情報が表示される' do
            find("#tasks-display-btn-#{routine.id}").click

            expect(page).to have_selector("#task-field-#{task1.id}")
            expect(page).to have_selector("#task-field-#{task2.id}")

            task1_field = find("#task-field-#{task1.id}")
            task2_field = find("#task-field-#{task2.id}")

            expect(task1_field).to have_content(task1.title)
            expect(task1_field).to have_content(tag1.name)
            expect(task1_field).to have_content('00 h')
            expect(task1_field).to have_content('01 m')
            expect(task1_field).to have_content('00 s')
            
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

      describe 'ヘッダーからのページ遷移' do
        it 'ロゴからマイページに遷移' do
          click_on 'logo-btn'
          expect(page).to have_current_path(my_pages_path)
        end

        it 'プロフィール詳細ページに遷移' do
          btn = find('#user-icon-btn')
          btn.click
          expect(page).to have_current_path(user_path(user))
        end

        describe 'Drawerメニュー' do
          # HeaderSupportモジュールのメソッドを使用
          it 'ルーティン作成ページに遷移' do
            check_new_routine_path
          end

          it 'ルーティン一覧に遷移' do
            check_routines_path
          end

          it '投稿一覧に遷移' do
            check_routines_posts_path
          end

          it 'マイページに遷移' do
            check_my_pages_path
          end

          it '称号一覧に遷移' do
            check_rewards_path
          end

          it 'ログアウト処理 => トップページに遷移' do
            check_logout
          end
        end
      end

      describe 'フッターからのページ遷移' do
        it '利用規約ページに遷移できる' do
          click_on '利用規約'
          expect(page).to have_current_path(terms_path)
        end

        it 'プライバシーポリシーページに遷移できる' do
          click_on 'プライバシーポリシー'
          expect(page).to have_current_path(policy_path)
        end
      end
    end
  end
end
