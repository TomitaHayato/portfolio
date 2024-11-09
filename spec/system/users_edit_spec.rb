require 'rails_helper'

RSpec.describe "EditUsers", type: :system, js: true do
  let!(:user) { create(:user, :for_system_spec) }
  let!(:user_other) { create(:user, :for_system_spec) }

    context 'ログイン前' do
      it 'アクセスに失敗し、ログイン画面に遷移する' do
        login_failed_check(edit_user_path(user))
      end
    end

    context 'ログイン後' do
      describe 'header/footerのテスト' do
        let!(:path) { edit_user_path(user) }
    
        context 'ログイン後' do
          it_behaves_like 'ログイン後Header/Footerテスト'
        end
      end

      before do
        login_as(user)
        visit edit_user_path(user)
      end

      it 'アクセスできる' do
        expect(page).to have_current_path edit_user_path(user)
      end

      describe 'パンくず' do
        let!(:breadcrumb_container) { find('.breadcrumbs-container-custom') }
  
        it '正しく表示される' do
          expect(breadcrumb_container).to have_selector "a[href='#{my_pages_path}']"
          expect(breadcrumb_container).to have_selector "a[href='#{user_path(user)}']"
          expect(breadcrumb_container).to have_content  '編集'
        end
  
        it 'マイページに遷移できる' do
          breadcrumb_container.find("a[href='#{my_pages_path}']").click
          expect(page).to have_current_path my_pages_path
        end
  
        it 'user_pathに遷移できる' do
          breadcrumb_container.find("a[href='#{user_path(user)}']").click
          expect(page).to have_current_path user_path(user)
        end
      end

    describe '編集フォームに関するテスト' do
      let!(:avatar_form) { find('#user_avatar')         }
      let!(:name_form)   { find('#user_name'  )         }
      let!(:email_form)  { find('#user_email' )         }
      let!(:submit_btn)  { find('input[type="submit"]') }

      it 'フォームが正しく表示されている' do
        expect(page).to have_selector "[id = 'preview']"
        expect(page).to have_selector '#user_avatar'
        expect(page).to have_selector '#user_name'
        expect(page).to have_selector '#user_email'
        expect(page).to have_selector 'input[type="submit"]'
      end

      it 'フォームの初期値が設定されている' do
        expect(name_form.value).to  eq user.name
        expect(email_form.value).to eq user.email
      end

      context 'フォームに正しい値を入力' do
        it 'ユーザー情報の更新に成功 => プロフィール画面に遷移' do
          name_form.set  'new name')
          email_form.set 'new@email.com')
          submit_btn.click
          # ページ
          expect(page).to           have_current_path user_path(user)
          expect(find('#flash')).to have_content      'プロフィールを更新しました'
          expect(page).to           have_content      'new name'
          expect(page).to           have_content      'new@email.com'
          # DB
          user.reload
          expect(user.name).to  eq 'new name'
          expect(user.email).to eq 'new@email.com'
        end
      end

      context 'フォームに不正な値を入力' do
        it 'ユーザー情報の更新に失敗 => プロフィール編集画面に戻る' do
          # 更新前のDB
          user_name_prev  = user.name
          user_email_prev = user.email
          #フォーム送信
          name_form.set('')
          email_form.set('')
          submit_btn.click
          # ページ
          expect(page).to have_current_path(edit_user_path(user))
          expect(page).to have_content('入力エラー')
          expect(page).to have_content('メールアドレスを入力してください')
          expect(page).to have_content('名前を入力してください')
          # DB
          user.reload
          expect(user.name).to  eq user_name_prev
          expect(user.email).to eq user_email_prev
        end
      end

      describe 'アバター画像の更新' do
        it 'avatarカラムに画像を登録できる' do
          user_avatar_prev = user.avatar
          #ファイルを添付
          attach_file('user_avatar', Rails.root.join('public', 'image_for_test.png'))
          submit_btn.click
          #DBの確認
          user.reload
          expect(user.avatar).not_to eq user_avatar_prev
        end

        it 'プレビュー機能'
          img_container = find('#img-zone')
          #ファイルを添付する前のimg要素
          img_src_prev = img_container.find('img["src"]')
          #ファイルを添付
          attach_file('user_avatar', Rails.root.join('public', 'image_for_test.png'))
          sleep 0.1
          # img要素が変化しているか
          img_src_now = img_container.find('img["src"]')
          expect(img_src_now).not_to eq img_src_prev
        end
      end
    end

    describe 'フォーム以外の要素のテスト' do
      it '「キャンセル」でプロフィール画面に戻れる' do
        click_on 'キャンセル'
        expect(page).to have_current_path(user_path(user))
      end
    end
  end
end
