require 'rails_helper'

RSpec.describe "Routines#index", type: :system, js: true do
  let!(:user)          { create(:user, :for_system_spec) }
  let!(:user_other)    { create(:user, :for_system_spec) }

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

    it 'ページに遷移できる' do
      expect(page).to have_current_path(routines_path)
    end

    describe 'header/footerのテスト' do
      context 'ログイン後' do
        it_behaves_like 'ログイン後Header/Footerテスト'
      end
    end

    describe 'パンくず' do
      let!(:breadcrumb_container) { find('.breadcrumbs-container-custom') }

      it '正しく表示される' do
        expect(breadcrumb_container).to have_selector "a[href='#{my_pages_path}']"
        expect(breadcrumb_container).to have_content  'My ルーティン'
      end

      it 'マイページに遷移できる' do
        breadcrumb_container.find("a[href='#{my_pages_path}']").click

        expect(page).to have_current_path my_pages_path
      end
    end

    context 'user.routinesがない' do
      before do
        @routines_container = find('#routine-index-page')
      end

      it 'ルーティンを作成しましょうと表示' do
        expect(@routines_container).to have_content 'ルーティンがありません ルーティンを作成しましょう！！'
      end

      it '検索フォームとクイック作成ボタンが表示' do
        expect(@routines_container).to have_selector '#user_words'
        expect(@routines_container).to have_selector '#search-btn'
        expect(@routines_container).to have_selector '#column'
        expect(@routines_container).to have_selector '#direction'
        expect(@routines_container).to have_selector '#filter_target'
        expect(@routines_container).to have_selector '#quick-create-routine-btn'
      end

      describe '1clickでルーティンを作成する機能' do
        let!(:quick_routine_template) { create(:quick_routine_template, user: user) }
        
        before do
          create(:tag, name: "日課")
        end

        it 'ルーティンを1clickで作成できる' do
          routine_size_prev = user.routines.count
          find('#quick-create-routine-btn').click
          sleep 0.1
          routine_size_new = user.routines.count
          new_routine      = user.routines.last
          new_routine_id   = new_routine.id
          #View
          expect(page).to have_current_path routine_path(new_routine_id)
          expect(page).to have_content 'ルーティンを作成しました'
          #DB
          expect(routine_size_new).to eq routine_size_prev + 1
          expect(new_routine).to have_attributes(
                                                  title:        quick_routine_template.title,
                                                  description:  quick_routine_template.description,
                                                  start_time:   quick_routine_template.start_time
                                                )
        end
      end
    end

    context 'user.routinesがある' do
      let!(:routine)       { create(:routine, user: user, title: 'ルーティン1') }
      let!(:routine2)      { create(:routine, user: user, title: 'ルーティン2', completed_count: 1) }
      let!(:routine_other) { create(:routine, user: user_other) }

      let!(:task)          { create(:task,    routine: routine) }
      let!(:tag)           { create(:tag) }
      let!(:task_tag)      { create(:task_tag, task: task, tag: tag) }

      before do
        visit routines_path
        @routines_container = find('#routine-index-page')
      end

      it '検索フォームが表示' do
        expect(@routines_container).to have_selector('#user_words')
        expect(@routines_container).to have_selector('#search-btn')
        expect(@routines_container).to have_selector('#column')
        expect(@routines_container).to have_selector('#direction')
        expect(@routines_container).to have_selector('#filter_target')
      end
      
      it 'ルーティン情報が表示' do
        # routineの情報
        expect(@routines_container).to have_selector("#routine-#{routine.id}")
        routine_container = find("#routine-#{routine.id}")
        expect(routine_container).to have_content routine.title
        expect(routine_container).to have_content routine.description
        expect(routine_container).to have_content routine.start_time.strftime('%H:%M')
        expect(routine_container).to have_content routine.completed_count
        # routineのリンク
        expect(routine_container).to have_selector "#show-routine-btn-#{routine.id}"
        expect(routine_container).to have_selector "#delete-routine-btn-#{routine.id}"
        expect(routine_container).to have_selector "#post-btn-#{routine.id}"
        expect(routine_container).to have_selector "#active-btn-#{routine.id}"
        # routine2の情報
        expect(@routines_container).to     have_selector("#routine-#{routine2.id}")
        # routine_otherの情報が表示されない
        expect(@routines_container).not_to have_selector("#routine-#{routine_other.id}")
      end

      it 'ルーティンのタスク一覧が表示' do
        find("#tasks-display-btn-#{routine.id}").click
        expect(page).to have_content(task.title)
        expect(page).to have_content(tag.name)
      end

      describe '各リンクの遷移テスト' do
        it 'ルーティン詳細画面に遷移できる' do
          find("#routine-#{routine.id}").find("#show-routine-btn-#{routine.id}").click

          expect(page).to have_current_path(routine_path(routine))
        end

        it 'ルーティンを削除できる' do
          page.accept_confirm("#{routine.title}を削除してもよろしいですか？") do
            find("#routine-#{routine.id}").find("#delete-routine-btn-#{routine.id}").click
          end

          expect(page).to           have_current_path(routines_path)
          expect(find('#flash')).to have_content("#{routine.title}を削除しました")
          expect(page).not_to       have_selector("#routine-#{routine.id}")
        end

        it 'ルーティンを投稿できる' do
          # 「投稿する」を押すと投稿中になる
          find("#post-btn-#{routine.id}").click
          # ページ上の確認
          expect(page).to have_current_path(routines_path)
          expect(page).to have_content('ルーティンを投稿しました')
          expect(page).to have_selector("#unpost-btn-#{routine.id}")
          # DBの確認
          routine.reload
          expect(routine.is_posted).to eq true

          # 「投稿済み」を押すと、非公開になる
          find("#unpost-btn-#{routine.id}").click
          # ページ上の確認
          expect(page).to have_current_path(routines_path)
          expect(page).to have_content('ルーティンを非公開にしました')
          expect(page).to have_selector("#post-btn-#{routine.id}")
          # DBの確認
          routine.reload
          expect(routine.is_posted).to eq false
        end

        it 'ルーティンを実践中にできる' do
          # 「実践中」を押すと、ルーティンを実践中にできる
          find("#active-btn-#{routine2.id}").click
          # ページ上の確認
          expect(page).to have_current_path(routines_path)
          expect(page).to have_selector("#active-now-#{routine2.id}")
          # DBの確認
          routine2.reload
          expect(routine2.is_active).to eq true

          # ルーティンを実践すると、他のルーティンは非アクティブになる
          find("#active-btn-#{routine.id}").click
          # ページ上の確認
          expect(page).to     have_current_path(routines_path)
          expect(page).to     have_selector("#active-now-#{routine.id}")
          expect(page).not_to have_selector("#active-now-#{routine2.id}")
          # DBの確認
          routine.reload
          routine2.reload
          expect(routine.is_active).to  eq true
          expect(routine2.is_active).to eq false
        end
      end

      describe 'ページネーション' do
        let!(:routine3)     { create(:routine, user: user, title: 'ルーティン3') }
        let!(:routine4)     { create(:routine, user: user, title: 'ルーティン4') }
        let!(:routine5)     { create(:routine, user: user, title: 'ルーティン5') }
        let!(:routine6)     { create(:routine, user: user, title: 'ルーティン6') }
        let!(:routine7)     { create(:routine, user: user, title: 'ルーティン7') }
        let!(:routine8)     { create(:routine, user: user, title: 'ルーティン8') }
        let!(:routine9)     { create(:routine, user: user, title: 'ルーティン9') }
        let!(:routine10)    { create(:routine, user: user, title: 'ルーティン10') }
        # 見切れるルーティン
        let!(:routine_over) { create(:routine, user: user, title: 'ルーティンOver', created_at: 1.day.ago) }

        before do
          visit routines_path
          @routines_container = find('#routine-index-page')
        end

        it '10件ずつ表示される' do
          expect(@routines_container).to     have_selector "#routine-#{routine.id}"
          expect(@routines_container).to     have_selector "#routine-#{routine10.id}"
          expect(@routines_container).not_to have_selector "#routine-#{routine_over.id}"
        end

        it '次のページに遷移できる' do
          find('.next a').click
          expect(page).to                    have_current_path(routines_path), ignore_query: true
          expect(@routines_container).not_to have_selector "#routine-#{routine.id}"
          expect(@routines_container).not_to have_selector "#routine-#{routine10.id}"
          expect(@routines_container).to     have_selector "#routine-#{routine_over.id}"
        end

        it '前のページに遷移できる' do
          find('.next a').click

          find('.prev a').click
          expect(page).to have_current_path(routines_path)

          expect(@routines_container).to     have_selector "#routine-#{routine.id}"
          expect(@routines_container).to     have_selector "#routine-#{routine10.id}"
          expect(@routines_container).not_to have_selector "#routine-#{routine_over.id}"
        end
      end
  

      describe 'ルーティン検索機能' do
        let!(:search_form) { find('#user_words') }

        it 'ルーティンのタイトル or 説明文で検索できる' do
          # タイトルで検索
          search_form.set('ルーティン2')
          click_on '検索'
          expect(page).to     have_selector("#routine-index-page")
          expect(page).not_to have_selector("#routine-#{routine.id}")
          expect(page).to     have_selector("#routine-#{routine2.id}")
          expect(search_form.value).to eq 'ルーティン2'

          # 説明文で検索
          search_form.set(routine.description)
          click_on '検索'
          expect(page).to     have_selector("#routine-index-page")
          expect(page).to     have_selector("#routine-#{routine.id}")
          expect(page).not_to have_selector("#routine-#{routine2.id}")
          expect(search_form.value).to eq routine.description
        end

        describe 'ルーティンを絞り込める' do
          before do
            # routineを投稿
            click_on "post-btn-#{routine.id}"
          end

          it '投稿済み' do
            select '投稿済み', from: 'filter_target'
            click_on '検索'
            expect(page).to     have_selector("#routine-index-page")
            expect(page).to     have_selector("#routine-#{routine.id}")
            expect(page).not_to have_selector("#routine-#{routine2.id}")
          end
          
          it '未投稿のみ' do
            select '未投稿', from: 'filter_target'
            click_on '検索'
            expect(page).to     have_selector("#routine-index-page")
            expect(page).not_to have_selector("#routine-#{routine.id}")
            expect(page).to     have_selector("#routine-#{routine2.id}")
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

        describe '並び替え' do
          let!(:routine3) { create(:routine, user: user, completed_count: 100) }
          
          before do
            visit routines_path
          end

          it 'デフォルトで「作成日」の「降順」' do
            select   '降順', from: 'direction'
            click_on '検索'
            sleep 0.25
            routine_containers = all('.routine-field-class-for-test')
            sorted_routine     = user.routines.order(created_at: :desc)

            routine_containers.each_with_index do |routine_cont, index|
              expected_id = "routine-#{sorted_routine[index].id}"
              expect(routine_cont['id']).to eq expected_id
            end
          end

          it '昇順にできる' do
            select   '昇順', from: 'direction'
            click_on '検索'
            sleep 0.25
            routine_containers = all('.routine-field-class-for-test')
            sorted_routine     = user.routines.order(created_at: :asc)

            routine_containers.each_with_index do |routine_cont, index|
              expected_id = "routine-#{sorted_routine[index].id}"
              expect(routine_cont['id']).to eq expected_id
            end
          end

          it '達成数で並べ替えれる' do
            select   '達成数', from: 'column'
            click_on '検索'
            sleep 0.25
            routine_containers = all('.routine-field-class-for-test')
            sorted_routine     = user.routines.order(completed_count: :desc)

            routine_containers.each_with_index do |routine_cont, index|
              expected_id = "routine-#{sorted_routine[index].id}"
              expect(routine_cont['id']).to eq expected_id
            end
          end
        end

        it '検索のオートコンプリート機能を使える' do
          # 表示されるかどうか
          search_form.set('ル')
          option1 = find('#search-options p', text: "ルーティン1")
          option2 = find('#search-options p', text: "ルーティン2")
          expect(option1).to be_visible
          expect(option2).to be_visible
          # クリックして検索フォームに入力できるかどうか
          option1.click
          expect(search_form.value).to eq 'ルーティン1'
        end
      end
    end
  end
end
