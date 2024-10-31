module HeaderSupport

  # ボタンによるページ遷移のテスト
  def check_new_routine_path
    btn = btn_find('ルーティンを作成する')
    btn.click

    expect(page).to have_current_path(new_routine_path)
  end

  def check_routines_path
    btn = btn_find('My ルーティン')
    btn.click

    expect(page).to have_current_path(routines_path)
  end

  def check_my_pages_path
    btn = btn_find('マイページへ')
    btn.click

    expect(page).to have_current_path(my_pages_path)
  end

  def check_routines_posts_path
    btn = btn_find('投稿一覧を見る')
    btn.click

    expect(page).to have_current_path(routines_posts_path)
  end

  def check_rewards_path
    btn = btn_find('称号一覧')
    btn.click

    expect(page).to have_current_path(rewards_path)
  end
  
  def check_logout
    btn = btn_find('ログアウト')
    btn.click

    expect(page).to have_current_path(root_path)
    expect(page).to have_content('ログアウトしました。')
  end

  private

  # ヘッダーのdrawerメニュー内のボタンを取得
  def btn_find(link_text)
    find('label', text: '≡').click

    menu = find('#drawer-menu') # メニュー要素を返す
    btn = nil # btnをwithinスコープ外で事前に定義
    
    within(menu) do
      btn = find('a', text: link_text)
    end

    btn
  end
end