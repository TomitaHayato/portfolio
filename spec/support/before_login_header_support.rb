module BeforeLoginHeaderSupport
  def check_login_path(login_path)
    page_trans_test(login_path)
  end

  def check_root_path(root_path)
    page_trans_test(root_path)
  end

  def check_new_user_path(new_user_path)
    page_trans_test(new_user_path)
  end

  def check_guest_login_path
    find('#before-login-header').find('a', text: 'お試し').click

    expect(page).to have_current_path(my_pages_path)
    expect(page).to have_content('ゲストユーザー')
    expect(page).to have_content('ゲストログインしました。')
  end

  private

  def page_trans_test(destination_path)
    find('#before-login-header').find("a[href='#{destination_path}']").click

    expect(page).to have_current_path(destination_path)
  end
end