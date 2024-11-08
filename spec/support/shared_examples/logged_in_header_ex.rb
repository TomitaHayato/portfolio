# 外部で必要な処理
    # 以下の変数を定義
        # user:  ログインしたユーザーと一致させる
        # path:  テストを行うpath
RSpec.shared_examples 'Logged in Header/Footer Test' do

  before do
    login_as(user)
    visit path
  end
  
  describe 'ヘッダー' do
    it 'headerが表示されている' do
      logged_in_header_check
    end
    
    it 'ロゴをクリック=>マイページに遷移' do
      check_logo_to_my_pages_path
    end
    
    it 'ユーザーアイコン=>user_path(current_user)に遷移' do
      check_icon_to_user_path(user)
    end
    
    describe 'drawer内' do
      it 'my_pages_pathに遷移' do
        check_drawer_my_pages_path
      end
      
      it 'new_routine_pathに遷移' do
        check_drawer_new_routine_path
      end
      
      it 'routines_pathに遷移' do
        check_drawer_routines_path
      end
      
      it 'routines_postsに遷移' do
        check_drawer_routines_posts_path
      end
      
      it 'rewards_pathに遷移' do
        check_drawer_rewards_path
      end
      
      it 'termsに遷移' do
        check_drawer_terms_path
      end
      
      it 'policy_pathに遷移' do
        check_drawer_policy_path
      end

      it 'ログアウトできる' do
        check_drawer_logout
      end
    end
  end

  describe 'ヘッダー Menu' do
    it 'header menuが表示されている' do
      header_menu_check
    end

    it 'my_pages_pathに遷移' do
      check_menu_my_pages_path
    end
    
    it 'new_routine_pathに遷移' do
      check_menu_new_routine_path
    end
    
    it 'routines_pathに遷移' do
      check_menu_routines_path
    end
    
    it 'routines_posts_pathに遷移' do
      check_menu_routines_posts_path
    end
    
    it 'rewards_pathに遷移' do
      check_menu_rewards_path
    end

    it 'user_path(current_user)に遷移' do
      check_menu_user_path(user)
    end
  end

  describe 'フッター' do
    it 'フッターが表示されている' do
      footer_check
    end

    it '利用規約ページに遷移できる' do
      check_footer_terms_path
    end
    
    it 'プライバシーポリシーページに遷移できる' do
      check_footer_policy_path
    end
  end
end