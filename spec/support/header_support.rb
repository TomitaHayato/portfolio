module HeaderSupport
  # headerが表示されているか
  def logged_in_header_check
    header = find('header')
    expect(header['id']).to eq('logged-in-header')
  end

  # header menuが表示されているか
  def header_menu_check
    header = find('header')
    expect(header).to have_selector('#header-menu')
  end

  # ヘッダーに表示されているリンクのテスト
  def check_logo_to_my_pages_path
    find('header').find('#logo-btn').click
    expect(page).to have_current_path(my_pages_path)
  end

  def check_icon_to_user_path(current_user)
    find('header').find('#user-icon-btn').click
    expect(page).to have_current_path(user_path(current_user))
  end

  # drawer内のリンクからのページ遷移テスト
  def check_drawer_my_pages_path
    menu_page_trans_test(header_drawer_container, 'マイページへ', my_pages_path)
  end
  
  def check_drawer_new_routine_path
    menu_page_trans_test(header_drawer_container, 'ルーティンを作成する', new_routine_path)
  end

  def check_drawer_routines_path
    menu_page_trans_test(header_drawer_container, 'My ルーティン', routines_path)
  end

  def check_drawer_routines_posts_path
    menu_page_trans_test(header_drawer_container, '投稿を見る', routines_posts_path)
  end

  def check_drawer_rewards_path
    menu_page_trans_test(header_drawer_container, '称号一覧', rewards_path)
  end

  def check_drawer_terms_path
    menu_page_trans_test(header_drawer_container, '利用規約', terms_path)
  end
  
  def check_drawer_policy_path
    menu_page_trans_test(header_drawer_container, 'プライバシーポリシー', policy_path)
  end

  def check_drawer_logout
    menu_page_trans_test(header_drawer_container, 'ログアウト', root_path)

    expect(page).to have_content('ログアウトしました。')
  end


  # ヘッダーメニューのテスト
  def check_menu_my_pages_path
    menu_page_trans_test(header_menu_container, 'マイページ', my_pages_path)
  end

  def check_menu_routines_path
    menu_page_trans_test(header_menu_container, 'My ルーティン', routines_path)
  end

  def check_menu_new_routine_path
    menu_page_trans_test(header_menu_container, '新規作成', new_routine_path)
  end

  def check_menu_routines_posts_path
    menu_page_trans_test(header_menu_container, '投稿を見る', routines_posts_path)
  end

  def check_menu_rewards_path
    menu_page_trans_test(header_menu_container, '称号一覧', rewards_path)
  end

  def check_menu_user_path(current_user)
    menu_page_trans_test(header_menu_container, 'プロフィール', user_path(current_user))
  end

  private

  # ヘッダーメニューからのページ遷移をテストするコード
  def menu_page_trans_test(header_container, link_text, destination_path)
    header_container.find('a', text: link_text).click

    expect(page).to have_current_path(destination_path)
  end

  # ヘッダーメニュー要素を取得
  def header_menu_container
    find('#header-menu')
  end

  # ヘッダーのdrawer要素を取得
  def header_drawer_container
    find('label', text: '≡').click

    find('#drawer-menu') 
  end
end